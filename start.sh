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


# معالجة القيم الافتراضية إذا لم يتم تعيينها
export PASSWORD=${PASSWORD:-$(openssl rand -base64 12)}
export USER=${USER:-developer}
export PORT=${PORT:-8080}

# إنشاء المسارات إذا لم تكن موجودة
mkdir -p "${USER_DATA_DIR:-/home/$USER/.local/share/code-server}"
mkdir -p "${EXTENSIONS_DIR:-/home/$USER/.local/share/code-server/extensions}"
mkdir -p "${LOG_DIR:-/home/$USER/.local/share/code-server/logs}"

# بدء code-server مع التهيئة الذكية
exec code-server \
  --config /path/to/config.yaml \
  --bind-addr 0.0.0.0:${PORT:-8080} \
  --auth password \
  --password "${PASSWORD:-default_password}" \
  --disable-telemetry \
  --header "X-Frame-Options: DENY" \
  --header "Content-Security-Policy: default-src 'self'" \
  --header "X-Content-Type-Options: nosniff" \
  /home/developer/workspace
