#!/bin/bash

# القيم الافتراضية الآمنة
USER=${USER:-developer}
PASSWORD=${PASSWORD:-$(openssl rand -base64 12)}
WORKSPACE_DIR=${WORKSPACE_DIR:-/home/${USER}/workspace}
CONFIG_DIR=${CONFIG_DIR:-/home/${USER}/.config/code-server}
EXTENSIONS_DIR=${EXTENSIONS_DIR:-/home/${USER}/.local/share/code-server/extensions}

# إنشاء المجلدات الأساسية
mkdir -p ${WORKSPACE_DIR} ${CONFIG_DIR} ${EXTENSIONS_DIR}

# تسجيل الإعدادات (لأغراض تصحيح الأخطاء)
cat <<EOF
=== إعدادات التشغيل ===
المستخدم: ${USER}
كلمة المرور: ${PASSWORD}
مسار العمل: ${WORKSPACE_DIR}
مسار التكوين: ${CONFIG_DIR}
مسار الإضافات: ${EXTENSIONS_DIR}
======================
EOF

# كتابة ملف التكوين إذا لم يكن موجوداً
if [ ! -f "${CONFIG_DIR}/config.yaml" ]; then
  cat > "${CONFIG_DIR}/config.yaml" <<- EOM
bind-addr: 0.0.0.0:10000
auth: password
password: ${PASSWORD}
cert: false
disable-telemetry: true
disable-update-check: true
EOM
fi

echo "=== معلومات الجلسة ==="
env | grep -E 'USER|PASSWORD|EXTENSIONS'
echo "=== محتويات مجلد التكوين ==="
ls -la $CONFIG_DIR





# بدء code-server
exec code-server \
  --bind-addr 0.0.0.0:8080 \
  --config "${CONFIG_DIR}/config.yaml" \
  --user-data-dir "/home/${USER}/.local/share/code-server" \
  --extensions-dir "${EXTENSIONS_DIR}" \
  --disable-telemetry \
  --disable-update-check \
  "${WORKSPACE_DIR}"
