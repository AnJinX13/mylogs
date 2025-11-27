#!/bin/bash

# =========================
# Docker Wrapper v2.3
# 多用户容器隔离 + 挂载管理 + 单日志
# =========================

# -------------------------
# 1. Config
# -------------------------
REAL_DOCKER="/usr/bin/docker"
USER_NAME="$(id -un)"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
WEIGHT_DIR="/home/weight/"
CONFIG_FILE="/etc/docker-wrapper/allowed_mounts.conf"
LOG_DIR="/var/log/docker-wrapper"
LOG_FILE="$LOG_DIR/docker-wrapper.log"

# -------------------------
# 2. 单日志函数（用户权限）
# -------------------------
log_action() {
    local action="$1"
    local command="$2"
    mkdir -p "$LOG_DIR"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$USER_NAME] $action: $command" >> "$LOG_FILE" 2>/dev/null || true
}

# -------------------------
# 3. 挂载配置函数
# -------------------------
load_mount_config() {
    declare -gA ALLOWED_MOUNTS
    
    # 默认路径（移除 USER_SPACE）
    ALLOWED_MOUNTS=(
        ["HOME"]="$USER_HOME/"
        ["WEIGHT"]="$WEIGHT_DIR"
        ["TMP"]="/tmp/"
    )
    
    if [ -f "$CONFIG_FILE" ]; then
        while IFS='=' read -r key path; do
            key=$(echo "$key" | tr '[:lower:]' '[:upper:]' | xargs)
            path=$(echo "$path" | xargs)
            [ -n "$key" ] && [ -n "$path" ] || continue
            path="${path/#\~/$USER_HOME}"
            ALLOWED_MOUNTS["$key"]="$path"
        done < "$CONFIG_FILE"
    fi
}

check_mount_permission() {
    local src="$1"
    load_mount_config
    for allowed in "${ALLOWED_MOUNTS[@]}"; do
        if [[ "$src" == "$allowed"* ]]; then
            return 0
        fi
    done
    return 1
}

# -------------------------
# 4. 挂载管理命令（Root 专用）
# -------------------------
case "$1" in
    --add-mount)
        if [ "$EUID" -ne 0 ]; then
            echo "[DENY] Only root can add mount paths"
            echo "Use: sudo docker --add-mount <path>"
            exit 1
        fi
        shift
        MOUNT_DIR="$1"
        mkdir -p "$(dirname $CONFIG_FILE)"
        if [ -z "$MOUNT_DIR" ] || [[ ! "$MOUNT_DIR" =~ ^/ ]] || [ ! -e "$MOUNT_DIR" ]; then
            echo "[ERROR] Invalid path: $MOUNT_DIR"
            exit 1
        fi
        KEY=$(basename "$MOUNT_DIR" | tr '[:lower:]' '[:upper:]' | tr -d ' /')
        if ! grep -q "^$KEY[[:space:]]*=[[:space:]]*" "$CONFIG_FILE" 2>/dev/null; then
            echo "$KEY=$MOUNT_DIR/" >> "$CONFIG_FILE"
        fi
        echo "[OK] Added: $KEY -> $MOUNT_DIR/"
        log_action "ADD_MOUNT" "docker --add-mount $MOUNT_DIR"
        exit 0
        ;;
    --rm-mount)
        if [ "$EUID" -ne 0 ]; then
            echo "[DENY] Only root can remove mount paths"
            exit 1
        fi
        shift
        KEY="$1"
        if [ -z "$KEY" ]; then
            echo "Usage: sudo docker --rm-mount <KEY>"
            docker --list-mounts
            exit 1
        fi
        if [ -f "$CONFIG_FILE" ] && grep -q "^${KEY}[[:space:]]*=[[:space:]]*" "$CONFIG_FILE"; then
            sed -i "/^${KEY}[[:space:]]*=/d" "$CONFIG_FILE"
            echo "[OK] Removed: $KEY"
            log_action "RM_MOUNT" "docker --rm-mount $KEY"
        else
            echo "[ERROR] Mount '$KEY' not found"
            echo "Available keys:"
            if [ -f "$CONFIG_FILE" ]; then
                grep '^[A-Z]' "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f1 | sed 's/[[:space:]]*$//'
            fi
        fi
        exit 0
        ;;
    --list-mounts)
        load_mount_config
        echo "=== Allowed Mount Paths ==="
        for key in "${!ALLOWED_MOUNTS[@]}"; do
            printf "  %-12s -> %s\n" "$key" "${ALLOWED_MOUNTS[$key]}"
        done
        exit 0
        ;;
esac

# -------------------------
# 5. 特殊命令直接透传
# -------------------------
case "$1" in
    --version|-v|version|--help|-h|help|docker)
        exec "$REAL_DOCKER" "$@"
        ;;
esac

# -------------------------
# 6. Root -> full access
# -------------------------
if [ "$EUID" -eq 0 ]; then
    exec "$REAL_DOCKER" "$@"
fi

# -------------------------
# 7. 解析命令
# -------------------------
COMMAND="$1"
shift
CMD=("$@")

log_action "EXEC" "docker $COMMAND ${CMD[*]}"

# -------------------------
# 8. 镜像命令 -> 直接透传
# -------------------------
IMAGE_COMMANDS=(images image rmi pull push tag build)
if printf '%s\n' "${IMAGE_COMMANDS[@]}" | grep -Fx "$COMMAND" > /dev/null; then
    exec "$REAL_DOCKER" "$COMMAND" "${CMD[@]}"
fi

# -------------------------
# 9. Deny --privileged
# -------------------------
for arg in "${CMD[@]}"; do
    if [[ "$arg" == "--privileged" ]]; then
        echo "[DENY] --privileged is not allowed for $USER_NAME"
        log_action "DENY_PRIVILEGED" "docker $COMMAND ${CMD[*]}"
        exit 1
    fi
done

# -------------------------
# 10. Validate mount paths
# -------------------------
if [[ "$COMMAND" == "run" || "$COMMAND" == "create" ]]; then
    for ((i=0; i<${#CMD[@]}; i++)); do
        if [[ "${CMD[$i]}" == "-v" || "${CMD[$i]}" == "--volume" || "${CMD[$i]}" == "--mount" ]]; then
            if [[ "${CMD[$i]}" == "--mount" ]]; then
                MOUNT_ARG="${CMD[$((i+1))]}"
                SRC=$(echo "$MOUNT_ARG" | sed -n 's/.*src=\([^,]*\).*/\1/p')
            else
                SRC="${CMD[$((i+1))]%:*}"
            fi
            if [ -n "$SRC" ] && [[ "$SRC" == /* ]] && ! check_mount_permission "$SRC"; then
                echo "[DENY] Invalid mount: $SRC"
                echo "Available paths:"
                load_mount_config
                for key in "${!ALLOWED_MOUNTS[@]}"; do
                    printf "  %-12s -> %s\n" "$key" "${ALLOWED_MOUNTS[$key]}"
                done
                log_action "DENY_MOUNT" "docker $COMMAND ${CMD[*]} ($SRC)"
                exit 1
            fi
        fi
    done
fi

# -------------------------
# 11. Inject owner label（精确位置）
# -------------------------
if [[ "$COMMAND" == "run" || "$COMMAND" == "create" ]]; then
    for ((i=0; i<${#CMD[@]}; i++)); do
        if [[ "${CMD[$i]}" == "--name" ]]; then
            OLD_NAME="${CMD[$((i+1))]}"
            NEW_NAME="${USER_NAME}_${OLD_NAME}"
            CMD[$((i+1))]="$NEW_NAME"
            echo "[INFO] Container renamed: $OLD_NAME -> $NEW_NAME" >&2
            break
        fi
    done
    
    NEW_CMD=()
    IMAGE_FOUND=false
    for arg in "${CMD[@]}"; do
        if [[ ! "$arg" =~ ^- ]] && [[ ! "$arg" =~ ^[a-zA-Z0-9_]+= ]] && ! "$IMAGE_FOUND"; then
            IMAGE_FOUND=true
            NEW_CMD+=("--label" "owner=$USER_NAME")
        fi
        NEW_CMD+=("$arg")
    done
    
    if ! "$IMAGE_FOUND"; then
        NEW_CMD+=("--label" "owner=$USER_NAME")
    fi
    CMD=("${NEW_CMD[@]}")
fi

# -------------------------
# 12. Container operation permission check
# -------------------------
NEED_TARGET_CHECK=(start stop restart kill rm inspect logs exec attach cp wait top stats)
if printf '%s\n' "${NEED_TARGET_CHECK[@]}" | grep -Fx "$COMMAND" > /dev/null; then
    TARGET="${CMD[0]}"
    if [ -n "$TARGET" ] && ! [[ "$TARGET" =~ ^[0-9a-f]{12,}$ ]]; then
        OWNER=$($REAL_DOCKER inspect -f '{{ index .Config.Labels "owner" }}' "$TARGET" 2>/dev/null || echo "")
        if [ "$OWNER" != "$USER_NAME" ] && [ "$OWNER" != "" ]; then
            echo "[DENY] You cannot operate on container '$TARGET'. Owner is '$OWNER'."
            log_action "DENY_CONTAINER" "docker $COMMAND $TARGET"
            exit 1
        fi
    fi
fi

# -------------------------
# 13. Container subcommand 处理
# -------------------------
if [[ "$COMMAND" == "container" ]]; then
    SUBCMD="${CMD[0]}"
    if [[ "$SUBCMD" == "ls" ]]; then
        exec "$REAL_DOCKER" container ls --filter "label=owner=$USER_NAME" "${CMD[@]:1}"
    fi
    if printf '%s\n' "${NEED_TARGET_CHECK[@]}" | grep -Fx "$SUBCMD" > /dev/null; then
        TARGET="${CMD[1]}"
        if [ -n "$TARGET" ] && ! [[ "$TARGET" =~ ^[0-9a-f]{12,}$ ]]; then
            OWNER=$($REAL_DOCKER inspect -f '{{ index .Config.Labels "owner" }}' "$TARGET" 2>/dev/null || echo "")
            if [ "$OWNER" != "$USER_NAME" ] && [ "$OWNER" != "" ]; then
                echo "[DENY] You cannot operate on container '$TARGET'. Owner is '$OWNER'."
                log_action "DENY_CONTAINER" "docker container $SUBCMD $TARGET"
                exit 1
            fi
        fi
        exec "$REAL_DOCKER" container "$SUBCMD" "${CMD[@]:1}"
    fi
    exec "$REAL_DOCKER" container "${CMD[@]}"
fi

# -------------------------
# 14. Auto filter for listing commands
# -------------------------
FILTER_ARGS=()
case "$COMMAND" in
    ps) FILTER_ARGS=(--filter "label=owner=$USER_NAME") ;;
    stats) FILTER_ARGS=(--filter "label=owner=$USER_NAME") ;;
esac

# -------------------------
# 15. Execute real docker
# -------------------------
exec "$REAL_DOCKER" "$COMMAND" "${FILTER_ARGS[@]}" "${CMD[@]}"
