FROM codercom/code-server:4.16.0

USER root

# تثبيت الحزم المطلوبة
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

# إعداد المستخدم والمجلدات
ARG USERNAME=developer
ARG USER_UID=1001
ARG USER_GID=1001

RUN groupadd --gid ${USER_GID} ${USERNAME} || true && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} || true && \
    mkdir -p /etc/sudoers.d && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${USERNAME} && \
    sudo chmod 0440 /etc/sudoers.d/${USERNAME}

# إنشاء المجلدات مسبقاً بصلاحيات صحيحة
RUN mkdir -p /home/${USERNAME}/workspace && \
    mkdir -p /home/${USERNAME}/.config/code-server && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# نسخ الملفات
COPY --chown=${USERNAME}:${USERNAME} settings.json /home/${USERNAME}/.config/code-server/
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# تثبيت الإضافات
RUN sudo -u ${USERNAME} code-server --install-extension ms-python.python && \
    sudo -u ${USERNAME} code-server --install-extension eamodio.gitlens

# تعيين المتغيرات البيئية
ENV SHELL=/bin/bash
ENV PASSWORD=${CODE_SERVER_PASSWORD:-secure@123}
ENV USERNAME=${USERNAME}
ENV CONFIG_DIR=/home/${USERNAME}/.config/code-server
ENV WORKSPACE_DIR=/home/${USERNAME}/workspace

USER ${USERNAME}
WORKDIR ${WORKSPACE_DIR}
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/start.sh"]
