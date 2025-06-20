#!/bin/bash

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
for extension in "${EXTENSIONS[@]}"; do
    code-server --install-extension "$extension"
done
