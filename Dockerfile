FROM codercom/code-server:latest

# تثبيت الحزم الأساسية
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# إنشاء المستخدم
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    mkdir -p /etc/sudoers.d && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# التحقق من التثبيت قبل تغيير المستخدم
RUN code-server --version

# نسخ الملفات
COPY --chown=${USERNAME}:${USERNAME} settings.json /home/${USERNAME}/.config/code-server/
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# تثبيت الإضافات
RUN sudo -u ${USERNAME} code-server --install-extension ms-python.python && \
    sudo -u ${USERNAME} code-server --install-extension eamodio.gitlens

EXPOSE 8080
USER ${USERNAME}
WORKDIR /home/${USERNAME}/workspace
ENTRYPOINT ["/usr/local/bin/start.sh"]
