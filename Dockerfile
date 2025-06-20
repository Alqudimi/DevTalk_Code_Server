# استخدام الصورة الأساسية لـ code-server مع أحدث إصدار من Ubuntu
FROM codercom/code-server:latest

# تعيين متغيرات البيئة
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV PATH="/home/coder/.local/bin:${PATH}"

# تثبيت التبعيات الأساسية والأدوات المطلوبة
RUN apt-get update && \
    apt-get install -y \
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
    rm -rf /var/lib/apt/lists/*

# تثبيت Node.js و npm و yarn لأدوات تطوير الويب
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    npm install -g yarn --ignore-deprecated

# تثبيت أدوات تطوير لغات البرمجة المختلفة
# Java
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk maven gradle && \
    rm -rf /var/lib/apt/lists/*

# Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    rm go1.21.0.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/coder/.cargo/bin:${PATH}"

# .NET Core
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-6.0 && \
    rm -rf /var/lib/apt/lists/*

# PHP
RUN apt-get update && \
    apt-get install -y php php-cli php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath && \
    rm -rf /var/lib/apt/lists/*

# Ruby
RUN apt-get update && \
    apt-get install -y ruby-full && \
    rm -rf /var/lib/apt/lists/*

# تثبيت Docker داخل Docker (لأغراض التطوير)
RUN curl -fsSL https://get.docker.com | sh

RUN curl -I https://open-vsx.org && \
    curl -I https://marketplace.visualstudio.com

# تثبيت أدوات CLI إضافية
RUN npm install -g \
    typescript \
    eslint \
    prettier \
    @angular/cli \
    @vue/cli \
    create-react-app

# تكوين Zsh كصدفة افتراضية مع Oh-My-Zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p ssh-agent \
    -p docker \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p https://github.com/zsh-users/zsh-autosuggestions

# نسخ ملفات التكوين المخصصة
COPY .zshrc /home/coder/.zshrc
COPY settings.json /home/coder/.local/share/code-server/User/settings.json

# تثبيت إضافات VS Code
COPY extensions.sh /usr/local/bin/install-extensions
RUN chown coder:coder /usr/local/bin/install-extensions && \
    chmod 755 /usr/local/bin/install-extensions && \
    su coder -c "/usr/local/bin/install-extensions"

# تعيين الأذونات والمستخدم
RUN chown -R coder:coder /home/coder && \
    usermod -aG sudo coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# تعيين مجلد العمل
WORKDIR /home/coder/project

# تعيين المنفذ
EXPOSE 8080

# الأمر الافتراضي لبدء الخدمة
ENTRYPOINT ["dumb-init", "code-server", "--bind-addr", "0.0.0.0:8080", "."]
