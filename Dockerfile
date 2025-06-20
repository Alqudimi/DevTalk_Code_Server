# استخدام الصورة الأساسية لـ code-server مع أحدث إصدار من Ubuntu
FROM codercom/code-server:latest

# تعيين متغيرات البيئة
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV PATH="/home/coder/.local/bin:${PATH}"

# تحديث الحزم الأساسية وتثبيت الأدوات الأساسية
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    curl \
    git \
    gnupg2 \
    htop \
    libssl-dev \
    net-tools \
    openssh-server \
    python3 \
    python3-pip \
    python3-venv \
    rsync \
    unzip \
    wget \
    zsh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# تثبيت Node.js و npm و yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest yarn --ignore-deprecated

# تثبيت أدوات تطوير لغات البرمجة
# Java
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    maven \
    gradle && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Go
RUN wget -q https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    rm go1.21.0.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/coder/.cargo/bin:${PATH}"

# .NET Core
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends dotnet-sdk-6.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# PHP
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    php \
    php-cli \
    php-common \
    php-mysql \
    php-zip \
    php-gd \
    php-mbstring \
    php-curl \
    php-xml \
    php-pear \
    php-bcmath && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ruby
RUN apt-get update && \
    apt-get install -y --no-install-recommends ruby-full && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# تثبيت Docker
RUN curl -fsSL https://get.docker.com | sh

# تثبيت أدوات CLI إضافية
RUN npm install -g \
    typescript \
    eslint \
    prettier \
    @angular/cli \
    @vue/cli \
    create-react-app

# تكوين Zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p ssh-agent \
    -p docker \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/zsh-users/zsh-autosuggestions

# نسخ ملفات التكوين
COPY .zshrc /home/coder/.zshrc
COPY settings.json /home/coder/.local/share/code-server/User/settings.json
COPY extensions.sh /usr/local/bin/install-extensions

# تعيين الأذونات
RUN chmod +x /usr/local/bin/install-extensions && \
    chown -R coder:coder /home/coder && \
    usermod -aG docker coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# تثبيت إضافات VS Code
USER coder
RUN /usr/local/bin/install-extensions

# إعدادات نهائية
USER root
WORKDIR /home/coder/project
EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server", "--bind-addr", "0.0.0.0:8080", "."]
