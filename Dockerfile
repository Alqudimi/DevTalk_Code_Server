# نستخدم الصورة الرسمية مباشرة بدون مراحل بناء
FROM codercom/code-server:4.22.0

# التبعيات الأساسية
RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    python3 \
    python3-pip \
    nodejs \
    npm \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# إعدادات المستخدم
ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# إنشاء المستخدم بدون صلاحيات root
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# إعداد البيئة
ENV SHELL=/bin/bash
ENV PASSWORD=${CODE_SERVER_PASSWORD:-changeme}
ENV CONFIG_DIR=/home/coder/.config/code-server
ENV EXTENSIONS_DIR=/home/coder/.local/share/code-server/extensions
ENV WORKSPACE_DIR=/home/coder/workspace

# إنشاء المجلدات الضرورية
RUN mkdir -p \
    ${CONFIG_DIR} \
    ${EXTENSIONS_DIR} \
    ${WORKSPACE_DIR} && \
    chown -R coder:coder /home/coder

# نسخ الإعدادات المخصصة
COPY settings.json ${CONFIG_DIR}/
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# تثبيت الأدوات الأساسية
RUN npm install -g yarn && \
    pip3 install --upgrade pip && \
    pip3 install docker-compose

# المنفذ المكشوف
EXPOSE 8080

# نقطة الدخول
USER coder
WORKDIR ${WORKSPACE_DIR}
ENTRYPOINT ["/usr/local/bin/start.sh"]
