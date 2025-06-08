#!/bin/bash

# استخدام القيم من ENV أو القيم الافتراضية الآمنة
USERNAME=${USERNAME:-developer}
WORKSPACE_DIR=${WORKSPACE_DIR:-/home/${USERNAME}/workspace}
CONFIG_DIR=${CONFIG_DIR:-/home/${USERNAME}/.config/code-server}
PASSWORD=${PASSWORD:-secure@123}

# تسجيل الإعدادات للتصحيح
echo "Starting with configuration:"
echo "USERNAME: ${USERNAME}"
echo "WORKSPACE_DIR: ${WORKSPACE_DIR}"
echo "CONFIG_DIR: ${CONFIG_DIR}"
echo "PASSWORD: ${PASSWORD}"

# التأكد من وجود المجلدات (تم إنشاؤها مسبقاً في Dockerfile)
if [ ! -d "${WORKSPACE_DIR}" ]; then
    echo "Warning: Workspace directory missing, trying to create..."
    mkdir -p "${WORKSPACE_DIR}" || { echo "Error: Failed to create workspace directory"; exit 1; }
fi

if [ ! -d "${CONFIG_DIR}" ]; then
    echo "Warning: Config directory missing, trying to create..."
    mkdir -p "${CONFIG_DIR}" || { echo "Error: Failed to create config directory"; exit 1; }
fi

# إعداد ملف config.yaml
cat > "${CONFIG_DIR}/config.yaml" <<- EOM
bind-addr: 0.0.0.0:8080
auth: password
password: ${PASSWORD}
cert: false
EOM

# بدء code-server
exec code-server \
  --bind-addr 0.0.0.0:8080 \
  --auth password \
  --password "${PASSWORD}" \
  --disable-telemetry \
  --disable-update-check \
  "${WORKSPACE_DIR}"
