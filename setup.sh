#!/bin/bash

# Atualiza o sistema e instala as dependências necessárias
sudo dnf update -y

# Instala o Node.js e npm (substitua por uma versão específica se necessário)
sudo dnf install -y nodejs npm unzip

# Instala o PM2 globalmente
sudo npm install -g pm2

# Define a variável de versão e o nome da pasta
VERSION="1.0.0"
APP_NAME="aws-app-hub-api"

# Baixa o arquivo zip da release
curl -L -o "${APP_NAME}.zip" "https://github.com/abel-cabral/abel-dockManager/releases/download/v${VERSION}/v${VERSION}.zip"

# Cria a pasta do aplicativo
mkdir "${APP_NAME}"

# Extrai o conteúdo do zip para a pasta do aplicativo
unzip "${APP_NAME}.zip" -d "${APP_NAME}"

# Navega até o diretório da aplicação
cd "${APP_NAME}" || exit

# Inicia a aplicação com PM2, rodando o arquivo app.js
pm2 start ./build/app.js --name "${APP_NAME}"

# Configura o PM2 para iniciar no boot do sistema
pm2 startup systemd

# Salva a configuração atual do PM2
pm2 save

# Exibe o status do PM2
pm2 status
