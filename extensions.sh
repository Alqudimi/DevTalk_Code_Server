#!/bin/bash
set -x  # تفعيل وضع التصحيح

exec > >(tee -a /var/log/extensions-install.log) 2>&1

# إعداد متغيرات البيئة
export PATH="$PATH:/home/coder/.local/bin"
echo "بدء تثبيت الإضافات..."

# قائمة بإضافات VS Code المطلوبة
EXTENSIONS=(
    # GitLens وأدوات Git
    "eamodio.gitlens"
    
    # دعم اللغات الأساسية
    "ms-python.python"
    "redhat.java"
    "golang.go"
    "rust-lang.rust"
    "ms-dotnettools.csharp"
    "bmewburn.vscode-intelephense-client"
    "rebornix.ruby"
    
    # أدوات الويب
    "octref.vetur"
    "angular.ng-template"
    "vue.volar"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    
    # قواعد البيانات
    "mtxr.sqltools"
    "mtxr.sqltools-driver-pg"
    
    # Docker و Kubernetes
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    
    # أدوات DevOps
    "hashicorp.terraform"
    "redhat.vscode-yaml"
    
    # واجهات برمجة التطبيقات (APIs)
    "postman.postman-for-vscode"
    "rangav.vscode-thunder-client"
    
    # أدوات إضافية
    "visualstudioexptteam.vscodeintellicode"
    "streetsidesoftware.code-spell-checker"
    "usernamehw.errorlens"
    "gruntfuggly.todo-tree"
)

# تثبيت كل الإضافات
install_extension() {
    local extension=$1
    local max_attempts=3
    local attempt=0
    local success=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        echo "محاولة تثبيت الإضافة $extension (المحاولة $((attempt+1)))"
        if code-server --install-extension "$extension"; then
            echo "تم تثبيت $extension بنجاح"
            success=1
            break
        else
            echo "فشل تثبيت $extension"
            sleep $((attempt+1))  # انتظر فترة أطول مع كل محاولة فاشلة
        fi
        ((attempt++))
    done
    
    if [[ $success -eq 0 ]]; then
        echo "تحذير: فشل تثبيت الإضافة $extension بعد $max_attempts محاولات"
        # لا توقف العملية عند فشل إضافة واحدة
    fi
}

# تثبيت كل الإضافات
for extension in "${EXTENSIONS[@]}"; do
    install_extension "$extension"
done

echo "اكتمل تثبيت الإضافات!"
exit 0  
