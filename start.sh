#!/bin/bash

# استخدام القيم من ENV أو القيم الافتراضية
USERNAME=${USERNAME:-developer}
WORKSPACE_DIR=${WORKSPACE_DIR:-/home/${USERNAME}/workspace}
CONFIG_DIR=${CONFIG_DIR:-/home/${USERNAME}/.config/code-server}
PASSWORD=${PASSWORD:-secure@123}
PORT=${PORT:-8080}

# إنشاء المجلدات إذا لم تكن موجودة
mkdir -p "${WORKSPACE_DIR}" || { echo "Error: Failed to create workspace directory"; exit 1; }
mkdir -p "${CONFIG_DIR}" || { echo "Error: Failed to create config directory"; exit 1; }
mkdir -p "/home/${USERNAME}/.local/share/code-server/extensions" || { echo "Error: Failed to create extensions directory"; exit 1; }

# إنشاء ملف config.yaml إذا لم يكن موجوداً
if [ ! -f "${CONFIG_DIR}/config.yaml" ]; then
    cat > "${CONFIG_DIR}/config.yaml" <<- EOM
bind-addr: 0.0.0.0:${PORT}
auth: password
password: ${PASSWORD}
cert: false
disable-telemetry: true
disable-update-check: true
disable-workspace-trust: true
EOM
fi

# ضبط صلاحيات الملفات
chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# بدء code-server
exec code-server \
    --bind-addr 0.0.0.0:${PORT} \
    --auth password \
    --password "${PASSWORD}" \
    --disable-telemetry \
    --disable-update-check \
    --user-data-dir "/home/${USERNAME}/.local/share/code-server" \
    --extensions-dir "/home/${USERNAME}/.local/share/code-server/extensions" \
    "${WORKSPACE_DIR}"
