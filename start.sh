#!/bin/bash


mkdir -p ${WORKSPACE_DIR}


if [ ! -f "${CONFIG_DIR}/config.yaml" ]; then
    cat > ${CONFIG_DIR}/config.yaml <<- EOM
bind-addr: 0.0.0.0:8080
auth: password
password: ${PASSWORD}
cert: false
EOM
fi


EXTENSIONS=(
    "ms-python.python"
    "ms-toolsai.jupyter"
    "eamodio.gitlens"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
)

for extension in "${EXTENSIONS[@]}"; do
    code-server --install-extension ${extension} --extensions-dir ${EXTENSIONS_DIR}
done


exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --auth password \
    --password ${PASSWORD} \
    --disable-telemetry \
    --disable-update-check \
    --user-data-dir ${CONFIG_DIR} \
    --extensions-dir ${EXTENSIONS_DIR} \
    ${WORKSPACE_DIR}