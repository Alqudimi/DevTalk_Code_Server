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

# التأكد من وجود المجلدات
mkdir -p "${WORKSPACE_DIR}" || { echo "Error: Failed to create workspace directory"; exit 1; }
mkdir -p "${CONFIG_DIR}" || { echo "Error: Failed to create config directory"; exit 1; }

# إعداد ملف config.yaml
cat > "${CONFIG_DIR}/config.yaml" <<- EOM
bind-addr: 0.0.0.0:8080
auth: password
password: ${PASSWORD}
cert: false
EOM

# تصدير متغير PASSWORD للبيئة
export PASSWORD

# بدء code-server (بدون --password في سطر الأوامر)
exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --header "X-Frame-Options: DENY" \
    --header "X-Content-Type-Options: nosniff" \
    --header "Content-Security-Policy: default-src 'self'" \
    --auth password \
    --disable-telemetry \
    "${WORKSPACE_DIR}"
