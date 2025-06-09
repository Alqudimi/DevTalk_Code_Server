FROM codercom/code-server:4.16.0

# جميع العمليات كـ root
USER root

# تثبيت التبعيات الأساسية
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# إعداد المستخدم والمجلدات
ARG USERNAME=developer
ARG USER_UID=1001
ARG USER_GID=1001

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    mkdir -p /etc/sudoers.d && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    mkdir -p /home/${USERNAME}/.local/share/code-server/extensions && \
    mkdir -p /home/${USERNAME}/.config/code-server && \
    mkdir -p /home/${USERNAME}/workspace && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# نسخ ملفات التكوين
COPY --chown=${USERNAME}:${USERNAME} config.yaml /home/${USERNAME}/.config/code-server/
COPY --chown=${USERNAME}:${USERNAME} settings.json /home/${USERNAME}/.config/code-server/
COPY --chown=${USERNAME}:${USERNAME} start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# تثبيت الإضافات
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension eamodio.gitlens && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local

# تعيين المتغيرات البيئية
ENV SHELL=/bin/bash
ENV USER=${USERNAME}
ENV PASSWORD=${CODE_SERVER_PASSWORD:-secure@123}
ENV CONFIG_DIR=/home/${USERNAME}/.config/code-server
ENV WORKSPACE_DIR=/home/${USERNAME}/workspace
ENV EXTENSIONS_DIR=/home/${USERNAME}/.local/share/code-server/extensions

# التبديل إلى المستخدم العادي
USER ${USERNAME}
WORKDIR ${WORKSPACE_DIR}
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/start.sh"]
