#!/bin/bash

# Atualizar o sistema
sudo yum update -y

# Instalar o Docker
sudo yum install docker -y

# Habilitar e iniciar o serviço Docker
sudo systemctl enable docker
sudo systemctl start docker

# Adicionar o usuário atual ao grupo docker
sudo usermod -a -G docker ec2-user

# Instalar utilitários do Amazon EFS
sudo yum install amazon-efs-utils -y

# Criar o ponto de montagem do EFS
sudo mkdir /mnt/efs

# Montar o EFS
echo "fs-0fe5064410e40e274.efs.us-east-1.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
sudo mount -a

# Baixar o Docker Compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Criar a configuração do Docker Compose
cat << EOF > /home/ec2-user/docker-compose.yaml
version: "3.8"

services:
  wordpress:
    image: wordpress
    volumes:
      - /mnt/efs/website:/var/www/html
    ports:
      - "80:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: database-1.c1s8e2si6kq9.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: teste1234
      WORDPRESS_DB_NAME: wordpress
EOF

# Executar o Docker Compose
sudo chown -R ec2-user:ec2-user /home/ec2-user/docker-compose.yaml
sudo docker-compose -f /home/ec2-user/docker-compose.yaml up -d
