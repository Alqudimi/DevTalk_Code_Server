FROM codercom/code-server:latest

# تثبيت الحزم الأساسية بدون أخطاء
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    && sudo rm -rf /var/lib/apt/lists/*

# تثبيت Node.js بشكل منفصل
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && \
    sudo apt-get install -y nodejs && \
    sudo npm install -g yarn

# إعداد المستخدم بدون مشاكل الصلاحيات
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000
RUN sudo groupadd --gid ${USER_GID} ${USERNAME} || true && \
    sudo useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true && \
    sudo mkdir -p /etc/sudoers.d && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${USERNAME} && \
    sudo chmod 0440 /etc/sudoers.d/${USERNAME}

# إعداد البيئة
ENV SHELL=/bin/bash
ENV PASSWORD=${CODE_SERVER_PASSWORD:-secure@123}
ENV CONFIG_DIR=/home/${USERNAME}/.config/code-server
ENV WORKSPACE_DIR=/home/${USERNAME}/workspace

# نسخ الملفات مع الصلاحيات الصحيحة
COPY --chown=${USERNAME}:${USERNAME} settings.json ${CONFIG_DIR}/
COPY start.sh /usr/local/bin/
RUN sudo chmod +x /usr/local/bin/start.sh

# تثبيت الإضافات
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension eamodio.gitlens

EXPOSE 8080
USER ${USERNAME}
WORKDIR ${WORKSPACE_DIR}
ENTRYPOINT ["/usr/local/bin/start.sh"]
