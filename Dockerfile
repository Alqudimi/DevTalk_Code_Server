FROM codercom/code-server:4.16.0

USER root

# تثبيت الحزم الأساسية
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libssl-dev \
    zsh \
    sudo \
    nano \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Node.js و Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    npm install -g npm@latest

# إعداد المستخدم
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} || true && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true && \
    usermod -aG sudo ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# إنشاء المجلدات الأساسية
RUN mkdir -p /home/${USERNAME}/workspace && \
    mkdir -p /home/${USERNAME}/.config/code-server && \
    mkdir -p /home/${USERNAME}/.local/share/code-server/extensions && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# نسخ ملفات التهيئة
COPY --chown=${USERNAME}:${USERNAME} settings.json /home/${USERNAME}/.config/code-server/
COPY --chown=${USERNAME}:${USERNAME} start.sh /usr/local/bin/
COPY --chown=${USERNAME}:${USERNAME} config.yaml /home/${USERNAME}/.config/code-server/
RUN chmod +x /usr/local/bin/start.sh

# تثبيت إضافات VS Code
RUN su ${USERNAME} -c "code-server --install-extension ms-python.python" && \
    su ${USERNAME} -c "code-server --install-extension eamodio.gitlens" && \
    su ${USERNAME} -c "code-server --install-extension vscodevim.vim" && \
    su ${USERNAME} -c "code-server --install-extension esbenp.prettier-vscode" && \
    su ${USERNAME} -c "code-server --install-extension dbaeumer.vscode-eslint"

# تعيين المتغيرات البيئية
ENV SHELL=/bin/bash
ENV PASSWORD=${CODE_SERVER_PASSWORD:-secure@123}
ENV USERNAME=${USERNAME}
ENV CONFIG_DIR=/home/${USERNAME}/.config/code-server
ENV WORKSPACE_DIR=/home/${USERNAME}/workspace
ENV EXTENSIONS_DIR=/home/${USERNAME}/.local/share/code-server/extensions
ENV USER_DATA_DIR=/home/${USERNAME}/.local/share/code-server
ENV LOG_DIR=/home/${USERNAME}/.local/share/code-server/logs
ENV PORT=8080

USER ${USERNAME}
WORKDIR ${WORKSPACE_DIR}
EXPOSE ${PORT}
ENTRYPOINT ["/usr/local/bin/start.sh"]
