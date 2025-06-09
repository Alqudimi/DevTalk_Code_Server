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

# استبدال الجزء الخاص بإعدادات الأمان بهذا:

# إنشاء مجلد conf.d إذا لم يكن موجوداً وإضافة إعدادات الأمان
RUN mkdir -p /etc/nginx/conf.d && \
    echo "server_tokens off;" > /etc/nginx/conf.d/security.conf && \
    echo "add_header X-Frame-Options DENY;" >> /etc/nginx/conf.d/security.conf && \
    echo "add_header X-Content-Type-Options nosniff;" >> /etc/nginx/conf.d/security.conf && \
    echo "add_header Content-Security-Policy \"default-src 'self';\"" >> /etc/nginx/conf.d/security.conf && \
    echo "add_header Strict-Transport-Security \"max-age=63072000; includeSubDomains; preload\";" >> /etc/nginx/conf.d/security.conf

RUN chmod +x /usr/local/bin/start.sh

# تثبيت الإضافات
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension eamodio.gitlens && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local

# تعيين المتغيرات البيئية
ENV SHELL=/bin/bash
ENV USER=${USERNAME}
ENV PASSWORD=${CODE_SERVER_PASSWORD:-SecurePass@123}
ENV CONFIG_DIR=/home/${USERNAME}/.config/code-server
ENV WORKSPACE_DIR=/home/${USERNAME}/workspace
ENV EXTENSIONS_DIR=/home/${USERNAME}/.local/share/code-server/extensions

# التبديل إلى المستخدم العادي
USER ${USERNAME}
WORKDIR ${WORKSPACE_DIR}
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/start.sh"]
