#!/bin/bash

# Defina a variável CREDENCIAL; passe o valor no header de suas requisições {"credencial": "123456781"}
export CREDENCIAL=969369662

# Define as variáveis de uso
export APP_NAME="aws-app-hub-api"
export HOME=/home/ec2-user

# Atualiza o sistema e instala as dependências necessárias
sudo dnf update -y

# Instala o Docker
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Adiciona o usuário ec2-user ao grupo docker (será necessário logout e login do usuário)
sudo usermod -aG docker ec2-user

# Instala o Node.js, npm e unzip
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
cd "$HOME" || exit

# Salvando senha de validação de acesso de forma segura
echo -n "$CREDENCIAL" > credencial.txt

# Obtém o link do arquivo zip da última release via API do GitHub
echo "Obtendo o link da última versão da release via API do GitHub..."
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/abel-cabral/${APP_NAME}/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Erro ao obter o link de download da última release."
    exit 1
fi

# Baixa o arquivo zip da última release
curl -L -o "${APP_NAME}.zip" "$DOWNLOAD_URL"
if [ $? -ne 0 ] || [ ! -f "${APP_NAME}.zip" ]; then
    echo "Erro ao baixar o arquivo da release ou o arquivo está bloqueado."
    exit 1
fi

# Define permissão de leitura para o arquivo zip
chmod 644 "${APP_NAME}.zip"

# Verifica o arquivo baixado
file "${APP_NAME}.zip" | grep -q "Zip archive data"
if [ $? -ne 0 ]; then
    echo "O arquivo baixado não é um arquivo zip válido."
    exit 1
fi

# Cria a pasta do aplicativo se não existir
mkdir -p "${APP_NAME}"

# Extrai o conteúdo do zip para a pasta do aplicativo
echo "Extraindo o conteúdo do arquivo zip..."
unzip -o "${APP_NAME}.zip" -d "${APP_NAME}"
if [ $? -ne 0 ]; then
    echo "Erro ao extrair o arquivo zip. Verifique a integridade do arquivo."
    exit 1
fi

# Deleta o zip que foi extraído
rm -f "${APP_NAME}.zip"

# Inicia a aplicação com PM2, limitando o uso de memória a 70 MB
pm2 start "$HOME/${APP_NAME}/app.js" --name "${APP_NAME}" --max-memory-restart 70M

# Corrige as permissões da pasta .pm2 (ajuste as permissões para o rpc.sock e pub.sock)
sudo chown ec2-user:ec2-user "$HOME/.pm2/rpc.sock" "$HOME/.pm2/pub.sock"

# Garante que o usuário ec2-user tenha propriedade total sobre a pasta .pm2
sudo chown -R ec2-user:ec2-user /home/ec2-user/.pm2

# Configura o PM2 para iniciar no boot do sistema
pm2 startup systemd -u ec2-user --hp "$HOME"
pm2 save

# Exibe o status do PM2
pm2 status

# Inicializa o Docker Swarm
docker swarm init
