FROM codercom/code-server:4.22.0

# الخطوة 1: تحديث مصادر الحزم مع التعامل مع الأخطاء
RUN apt-get update || (apt-get update && sleep 60 && apt-get update) && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    sudo \
    python3 \
    python3-pip \
    nodejs \
    npm \
    openssh-client \  # تم تغييرها من openssh-server
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# الخطوة 2: تثبيت Node.js بشكل منفصل إذا فشل التثبيت السابق
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# إعدادات المستخدم والبيئة (كما هي)
ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# باقي الإعدادات...
COPY settings.json /home/coder/.config/code-server/
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8080
USER coder
WORKDIR /home/coder/workspace
ENTRYPOINT ["/usr/local/bin/start.sh"]
