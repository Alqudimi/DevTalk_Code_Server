# استخدام صورة Ubuntu 22.04 كقاعدة ثم تثبيت code-server يدوياً
FROM ubuntu:22.04

# تعيين متغيرات البيئة
ENV DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/bash \
    PATH="/home/coder/.local/bin:/usr/local/go/bin:/home/coder/.cargo/bin:${PATH}" \
    CODER_VERSION=4.23.0

# إنشاء مستخدم coder مع صلاحيات sudo
RUN useradd -m -s /bin/bash coder && \
    apt-get update && \
    apt-get install -y sudo && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/coder/.local/share/code-server/User && \
    chown -R coder:coder /home/coder

# تثبيت التبعيات الأساسية على مراحل
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
    zsh \
    ca-certificates \
    dumb-init \
    && rm -rf /var/lib/apt/lists/*

# تثبيت Node.js و npm و yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest yarn && \
    rm -rf /var/lib/apt/lists/*

# تثبيت أدوات تطوير اللغات
## Java
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk maven gradle && \
    rm -rf /var/lib/apt/lists/*

## Go
RUN curl -fsSL https://go.dev/dl/go1.21.0.linux-amd64.tar.gz | tar -C /usr/local -xz

## Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

## .NET Core
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-6.0 && \
    rm -rf /var/lib/apt/lists/*

## PHP
RUN apt-get update && \
    apt-get install -y php php-cli php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath && \
    rm -rf /var/lib/apt/lists/*

## Ruby
RUN apt-get update && \
    apt-get install -y ruby-full && \
    rm -rf /var/lib/apt/lists/*

# تثبيت Docker CLI فقط (بدون daemon)
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# تثبيت أدوات CLI إضافية
RUN npm install -g \
    typescript \
    eslint \
    prettier \
    @angular/cli \
    @vue/cli \
    create-react-app

# تثبيت Oh-My-Zsh مع plugins
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p ssh-agent \
    -p docker \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/zsh-users/zsh-autosuggestions

# تثبيت code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    rm -rf /var/lib/apt/lists/*

# نسخ ملفات التكوين
COPY .zshrc /home/coder/.zshrc
COPY settings.json /home/coder/.local/share/code-server/User/settings.json
COPY extensions.sh /usr/local/bin/install-extensions

# تعيين الأذونات وتثبيت الإضافات
RUN chmod +x /usr/local/bin/install-extensions && \
    chown coder:coder /usr/local/bin/install-extensions && \
    sudo -u coder /usr/local/bin/install-extensions

# تنظيف الذاكرة المؤقتة
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# تعيين مجلد العمل والمستخدم
WORKDIR /home/coder/project
USER coder
EXPOSE 8080

# أمر التشغيل
ENTRYPOINT ["dumb-init", "code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "."]
