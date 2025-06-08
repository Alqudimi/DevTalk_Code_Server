# استخدام الصورة الرسمية الأحدث
FROM codercom/code-server:latest

# تثبيت التبعيات الأساسية مع معالجة الأخطاء
RUN sudo apt-get update && \
    sudo apt-get install -y \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && sudo rm -rf /var/lib/apt/lists/*

# إعداد Node.js وإدارة الإصدارات
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && \
    sudo apt-get install -y nodejs && \
    sudo npm install -g yarn

# إنشاء مستخدم غير root
ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN sudo groupadd --gid $USER_GID $USERNAME && \
    sudo useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL | sudo tee /etc/sudoers.d/$USERNAME && \
    sudo chmod 0440 /etc/sudoers.d/$USERNAME

# إعداد البيئة والمجلدات
ENV SHELL=/bin/bash
ENV PASSWORD=${CODE_SERVER_PASSWORD:-changeme}
ENV CONFIG_DIR=/home/coder/.config/code-server
ENV WORKSPACE_DIR=/home/coder/workspace

# نسخ ملفات الإعداد
COPY --chown=coder:coder settings.json $CONFIG_DIR/
COPY --chown=coder:coder start.sh /usr/local/bin/
RUN sudo chmod +x /usr/local/bin/start.sh

# تثبيت الإضافات الأساسية مسبقاً
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension eamodio.gitlens

# المنفذ ونقطة الدخول
EXPOSE 8080
USER coder
WORKDIR $WORKSPACE_DIR
ENTRYPOINT ["/usr/local/bin/start.sh"]
