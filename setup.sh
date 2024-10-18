#!/bin/bash

# Atualiza o sistema e instala as dependências necessárias
sudo dnf update -y

# Instala o Docker
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Adiciona o usuário ec2-user ao grupo docker
sudo usermod -aG docker ec2-user

# Instala o Node.js, npm e unzip (substitua por uma versão específica de Node.js se necessário)
sudo dnf install -y nodejs npm unzip

# Instala o PM2 globalmente
sudo npm install -g pm2

# Configura 2 GB de memória swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Define a variável de versão e o nome da pasta
VERSION="1.0.2"
APP_NAME="aws-app-hub-api"

# Muda para o diretório do usuário padrão (ec2-user)
cd /home/ec2-user || exit

# Baixa o arquivo zip da release
curl -L -o "${APP_NAME}.zip" "https://github.com/abel-cabral/abel-dockManager/releases/download/v${VERSION}/v${VERSION}.zip"

# Cria a pasta do aplicativo
mkdir "${APP_NAME}"

# Extrai o conteúdo do zip para a pasta do aplicativo
unzip "${APP_NAME}.zip" -d "${APP_NAME}"

# Deleta o zip que foi extraido
rm -rf "${APP_NAME}.zip"

# Navega até o diretório da aplicação
cd "${APP_NAME}" || exit

# Inicia a aplicação com PM2, limitando o uso de memória a 70 MB
pm2 start ./app.js --name "${APP_NAME}" --max-memory-restart 70M

# Configura o PM2 para iniciar no boot do sistema
pm2 startup systemd

# Salva a configuração atual do PM2
pm2 save

# Exibe o status do PM2
pm2 status

# Reinicia a sessão do usuário para garantir que o grupo docker seja atualizado
newgrp docker

# Inicializa o Docker Swarm
docker swarm init
