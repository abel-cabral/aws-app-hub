# Hub de Aplicações em AWS EC2
Este projeto tem como objetivo criar um hub de aplicações utilizando uma instância AWS EC2 com a imagem Amazon Linux 2023. O guia a seguir foi desenvolvido para ajudar desenvolvedores que precisam testar suas aplicações em um ambiente de servidor acessível, contínuo e sem custo adicional. A proposta é oferecer uma solução prática para manter serviços rodando 24 horas por dia, sem a necessidade de desligar a instância, garantindo a continuidade dos testes e desenvolvimentos. Basicamente dicas de como gerencias um "cluster" em uma instancia EC2 na AWS, permitindo ter varios serviços rodando na versão grátis (750 horas) da AWS.

## Comandos Úteis
Abaixo estão listados comandos essenciais para o gerenciamento e manutenção da sua instância EC2 e dos serviços Docker.

### Reiniciar a Instância
Para reiniciar a instância EC2 sem perder o IP público, o que pode acontecer ao reiniciar via painel da AWS, utilize o seguinte comando:
```bash
sudo reboot
```
Isso é útil para atualizar ou instalar pacotes sem precisar reconfigurar serviços que dependem do IP público.


### Verificar Memória Disponível
Para verificar a quantidade de memória disponível no sistema, utilize:
```bash
free -h
```


### Limpeza de Caches e Dados do Docker
Para limpar todos os caches e dados do Docker, incluindo containers parados, imagens e volumes, utilize:
```bash
docker stop $(docker ps -q) || true
docker rm $(docker ps -a -q) || true
docker rmi $(docker images -q) || true
docker volume rm $(docker volume ls -q) || true
docker network rm $(docker network ls -q) || true
docker builder prune -a -f
sudo rm -rf /var/lib/docker/containers/*/*.log
sudo rm -rf /var/lib/docker
```


### Verificar Armazenamento Disponível
Para exibir a quantidade de armazenamento do sistema, o que foi usado e o que está disponível, use:
```bash
df -h
```


### Gerenciamento de Docker Stack
Para fazer o deploy dos containers utilizando um arquivo docker-compose.yml para um cluster Docker Stack, utilize:
```bash
docker stack deploy -c docker-compose.yml service-name
```

Para remover um serviço específico no cluster Docker Stack:
```bash
docker stack rm service-name
```


### Build e Deploy de Imagens Docker
#### Build Universal de Imagem Docker:
Para construir uma imagem Docker universalmente compatível (incluindo arquiteturas ARM e x86-64):
```bash
docker buildx build --platform linux/amd64 -t username/my-repository:latest .
```

#### Login no Docker Hub:
```bash
docker login
```

#### Fazer Push da Imagem para o Docker Hub:
```bash
docker push username/my-repository:latest
```


### Monitoramento e Diagnóstico
Monitorar o Uso de Recursos dos Containers:
```bash
docker stats
```

Verificar o Status dos Serviços Docker Stack:
```bash
docker service ls
```
