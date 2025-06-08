FROM codercom/code-server:latest

USER root

RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod -R 0755 /var/lib/apt/lists

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
ARG USER_UID=1001
ARG USER_GID=1001

RUN if ! getent group ${USER_GID}; then \
        groupadd --gid ${USER_GID} ${USERNAME}; \
    else \
        groupmod -n ${USERNAME} $(getent group ${USER_GID} | cut -d: -f1); \
    fi

# إنشاء المستخدم إذا لم يكن موجوداً
RUN if ! id -u ${USERNAME}; then \
        useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}; \
    fi

# إعداد sudoers
RUN mkdir -p /etc/sudoers.d && \
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
