#!/bin/bash

# تأكد من وجود مجلد العمل
mkdir -p $WORKSPACE_DIR

# إنشاء ملف config إذا لم يكن موجوداً
if [ ! -f "$CONFIG_DIR/config.yaml" ]; then
    cat > $CONFIG_DIR/config.yaml <<- EOM
bind-addr: 0.0.0.0:8080
auth: password
password: $PASSWORD
cert: false
EOM
fi

# بدء code-server مع الإعدادات
exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --auth password \
    --password $PASSWORD \
    --disable-telemetry \
    --disable-update-check \
    $WORKSPACE_DIR
