# استخدام الصورة الأساسية لـ code-server مع أحدث إصدار من Ubuntu
FROM codercom/code-server:latest

# تعيين متغيرات البيئة
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV PATH="/home/coder/.local/bin:${PATH}"

# تثبيت التبعيات الأساسية والأدوات المطلوبة
RUN sudo apt-get update && \
    sudo apt-get install -y \
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
    sudo \
    unzip \
    wget \
    zsh && \
    sudo rm -rf /var/lib/apt/lists/*

# تثبيت Node.js و npm و yarn لأدوات تطوير الويب
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && \
    sudo apt-get install -y nodejs && \
    sudo npm install -g yarn

# تثبيت أدوات تطوير لغات البرمجة المختلفة
# Java
RUN sudo apt-get update && \
    sudo apt-get install -y openjdk-17-jdk maven gradle && \
    sudo rm -rf /var/lib/apt/lists/*

# Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && \
    sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz && \
    rm go1.21.0.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/coder/.cargo/bin:${PATH}"

# .NET Core
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    sudo apt-get update && \
    sudo apt-get install -y dotnet-sdk-6.0 && \
    sudo rm -rf /var/lib/apt/lists/*

# PHP
RUN sudo apt-get update && \
    sudo apt-get install -y php php-cli php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath && \
    sudo rm -rf /var/lib/apt/lists/*

# Ruby
RUN sudo apt-get update && \
    sudo apt-get install -y ruby-full && \
    sudo rm -rf /var/lib/apt/lists/*

# تثبيت Docker داخل Docker (لأغراض التطوير)
RUN curl -fsSL https://get.docker.com | sh

# تثبيت أدوات CLI إضافية
RUN sudo npm install -g \
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
COPY extensions.sh /tmp/extensions.sh

# تثبيت إضافات VS Code (بما في ذلك GitLens)
RUN chmod +x /tmp/extensions.sh && /tmp/extensions.sh

# تعيين الأذونات والمستخدم
RUN sudo chown -R coder:coder /home/coder && \
    sudo usermod -aG sudo coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# تعيين مجلد العمل
WORKDIR /home/coder/project

# تعيين المنفذ
EXPOSE 8080

# الأمر الافتراضي لبدء الخدمة
ENTRYPOINT ["dumb-init", "code-server", "--bind-addr", "0.0.0.0:8080", "."]
