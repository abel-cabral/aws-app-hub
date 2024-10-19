#!/bin/bash

# Defina a variável CREDENCIAL
export CREDENCIAL=123456781

# Define as variáveis de uso
export VERSION="1.0.3"
export APP_NAME="aws-app-hub-api"
export HOME=/home/ec2-user

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

# Muda para o diretório do usuário padrão (ec2-user)
cd /home/ec2-user || exit

# Salvado senha de validacao de acesso
echo "export CHAVE_DE_ACESSO=\"$CREDENCIAL\"" >> ~/.bashrc
source ~/.bashrc

# Baixa o arquivo zip da release
curl -L -o "${APP_NAME}.zip" "https://github.com/abel-cabral/abel-dockManager/releases/download/v${VERSION}/v${VERSION}.zip"

# Cria a pasta do aplicativo
mkdir "${APP_NAME}"

# Extrai o conteúdo do zip para a pasta do aplicativo
unzip "${APP_NAME}.zip" -d "${APP_NAME}"

# Deleta o zip que foi extraido
rm -rf "${APP_NAME}.zip"

# Inicia a aplicação com PM2, limitando o uso de memória a 70 MB
pm2 start "/home/ec2-user/${APP_NAME}/app.js" --name "${APP_NAME}" --max-memory-restart 70M
sudo chown ec2-user:ec2-user /home/ec2-user/.pm2/rpc.sock /home/ec2-user/.pm2/pub.sock

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
