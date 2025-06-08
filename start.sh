#!/bin/bash

# إنشاء مجلد العمل إذا لم يكن موجوداً
mkdir -p ${WORKSPACE_DIR}

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
  ${WORKSPACE_DIR}
