
FROM codercom/code-server:latest


FROM debian:12-slim


RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    wget \
    sudo \
    python3 \
    python3-pip \
    nodejs \
    npm \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*


COPY --from=builder /usr/local/bin/code-server /usr/local/bin/code-server
COPY --from=builder /usr/local/lib/code-server /usr/local/lib/code-server


RUN useradd -m -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd


ENV SHELL=/bin/bash
ENV PASSWORD=${CODE_SERVER_PASSWORD:-changeme}
ENV CONFIG_DIR=/home/coder/.config/code-server
ENV EXTENSIONS_DIR=/home/coder/.local/share/code-server/extensions
ENV WORKSPACE_DIR=/home/coder/workspace


RUN mkdir -p \
    ${CONFIG_DIR} \
    ${EXTENSIONS_DIR} \
    ${WORKSPACE_DIR} && \
    chown -R coder:coder /home/coder


COPY settings.json ${CONFIG_DIR}/
COPY start.sh /usr/local/bin/


RUN npm install -g yarn && \
    pip3 install --upgrade pip && \
    pip3 install docker-compose


EXPOSE 8080


USER coder
WORKDIR ${WORKSPACE_DIR}
ENTRYPOINT ["/usr/local/bin/start.sh"]