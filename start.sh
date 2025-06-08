#!/bin/bash

USERNAME=${USERNAME:-developer}
DEFAULT_WORKSPACE="/home/${USERNAME}/workspace"
DEFAULT_CONFIG="/home/${USERNAME}/.config/code-server"

WORKSPACE_DIR=${WORKSPACE_DIR:-$DEFAULT_WORKSPACE}
CONFIG_DIR=${CONFIG_DIR:-$DEFAULT_CONFIG}
PASSWORD=${PASSWORD:-password}

echo "Starting with configuration:"
echo "USERNAME: ${USERNAME}"
echo "WORKSPACE_DIR: ${WORKSPACE_DIR}"
echo "CONFIG_DIR: ${CONFIG_DIR}"
echo "PASSWORD: ${PASSWORD}"

mkdir -p "${WORKSPACE_DIR}" || { echo "Error: Failed to create workspace directory"; exit 1; }
mkdir -p "${CONFIG_DIR}" || { echo "Error: Failed to create config directory"; exit 1; }



# إعداد ملف الإعدادات إذا لم يوجد
if [ ! -f "${CONFIG_DIR}/config.yaml" ]; then
  cat > ${CONFIG_DIR}/config.yaml <<- EOM
bind-addr: 0.0.0.0:8080
auth: password
password: ${PASSWORD}
cert: false
EOM
fi

# بدء الخدمة
exec code-server \
  --bind-addr 0.0.0.0:8080 \
  --auth password \
  --password ${PASSWORD} \
  --disable-telemetry \
  --disable-update-check \
  ${WORKSPACE_DIR}} || { echo "Failed to start code-server"; exit 1; } 
  
