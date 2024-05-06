# Projeto-CompassUOL-AWS_DOCKER

# Instruções da atividade: 

1. Instalação e configuração do DOCKER ou CONTAINERD no host EC2;
(Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh))
2. Efetuar Deploy de uma aplicação Wordpress com: container de aplicação RDS database Mysql;
3. Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress;
4. Configuração do serviço de Load Balancer AWS para a aplicação Wordpress;

# Arquitetura
![image](https://github.com/Gustavopedoni1/Projeto-CompassUOL-AWS_DOCKER/assets/157602238/54982031-6a38-4acf-a328-e33254a6617a)

# Execução

# Criando VPC

Iniciei a arquitetura com a construção de uma VPC, com o seguinte passo a passo :

1. Ir ao painel VPC da AWS e selecionar a opção Suas VPCs;
2. Selecionar o botão **Criar VPC** no canto superior direito;
3. Selecionar VPC e muito mais _("Criar VPC e muito mais" na AWS facilita a configuração inicial de uma VPC ao fornecer recursos pré-configurados como sub-redes, gateways e tabelas de rotas)_
4. Escolher o nome da sua vpc e recursos _(no meu caso DOCKER)_;
5. Selecionar número de zonas de disponibilidades, por padrão são 2;
6. Finalizar no botão **Criar VPC**

Após a criação obtive o seguinte mapa de recursos da VPC:
![mapa de recursos vpc](https://github.com/Gustavopedoni1/Projeto-CompassUOL-AWS_DOCKER/assets/157602238/df25e461-2167-412c-83e8-58df16f195ff)

# Criando e configurando Grupos de Segurança 

Para um maior controle dos recursos da atividade criei 4 grupos de segurança com as seguintes regras :

• **Grupo de segurança para as instâncias**

| Tipo | Protocolo | Intervalo de portas | Destino |
|---|---|---|---|
| HTTP | TCP | 80 |Grupo de Segurança do Load balancers|
| SSH | TCP | 22 |0.0.0.0/0 |
| MYSQL/AURORA | TCP | 3306 | Grupo de Segurança do RDS|
| NFS | TCP | 2049 | Grupo de Segurança do EFS|

• **Grupo de segurança para o EFS**

| Tipo | Protocolo | Intervalo de portas | Destino |
|---|---|---|---|
| NFS | TCP | 2049 |Grupo de Segurança das Instâncias|

• **Grupo de segurança para O RDS**

| Tipo | Protocolo | Intervalo de portas | Destino |
|---|---|---|---|
| MYSQL/AURORA | TCP | 3306 | Grupo de Segurança das Instâncias|


• **Grupo de segurança para O Load balancers**

| Tipo | Protocolo | Intervalo de portas | Destino |
|---|---|---|---|
| HTTP | TCP | 80 |0.0.0.0/0|

# Criando o serviço de Elastic File System (EFS)

• No console AWS, naveguei até o serviço de EFS, no menu lateral esquerdo, cliquei em __Sistemas de arquivos__ e, na sequência, em __Criar sistema de arquivos__, Adicionei um nome e mantive as opções pré-definidas, alterei apenas o grupo de segurança para o grupo que criei para o serviço. 

# Criando o Relational Database Service (RDS)

• Fui até o painel RDS na AWS, selecionei __criar banco de dados__, segui a configuração de criação padrão escolhi **MySql** como opção de mecanismo, nas configurações criei um nome para a base, além de criar um nome de usuário principal e senha, escolhi a VPC e suas subredes criadas anteriormente já para a atividade e mantive o acesso privado, Selecionei o grupo de segurança criado para o RDS e mantive a Zona de disponibilidade sem preferência.

# Criando Modelo de Execução para a criação das instâncias

• No painel da EC2, __Modelos de Execução__ criei um modelo com as seguintes configurações:
**SO:** Amazon Linux AWS (2023)
**Tipo de instância:** t3.small
**Par de chaves:** uma já criada e em minha posse 
**Selecione grupo de segurança existente** (criado anteriormente)
**Tags de recursos:** informadas pela equipe Compass UOL de uso privado

Em "Detalhes Avançados", na seção "Dados do usuário", inseri o seguinte script:

```
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
```

# Criando Load Balancer 

• No painel do EC2 na AWS, selecionei o menu Load Balancers no lado esquerdo da tela;
Em __Criar Load Balancer__, nomei, mantive a opção __Voltado para a Internet__ marcada, em __Mapeamento de Rede__ selecionei a VPC criada para a atividade, assim como as subredes públicas de cada AZ, selecionei o Grupo de Segurança já criado para o serviço e em Listeners e roteamento adicionei um grupo de destino (não tinha grupo então criei um selecionando uma instancia inicializada com o modelo de execução citado a cima).

# Criando o Auto Scaling 

• No painel de ECS na AWS selecionei o menu Grupos do __Auto Scaling__, no lado esquerdo da tela, e a opção __Criar grupo do Auto Scaling__, criei um nome para o Auto Scaling e selecionei o Modelo de Execução criado,selecionei a VPC da atividade e duas subnets públicas. Em __Balanceamento de Carga__ marquei a opção __Anexar a um balanceador de carga existente__ para selecionar o Load Balancer criado anteriormente. Na pagina de configurações deixei:
Capacidade desejada: 2
Capacidade mínima desejada: 2
Capacidade máxima desejada: 2
Não fiz mais alterações finalizei a criação.

# Inicializando a instância 

• Tendo em vista que o Auto Scaling criou duas instâncias, escolhi uma e com seu ip fiz um acesso via SSH.

• Estando dentro da instância fiz algumas configurações:

- Usei o comando ``` docker ps ``` para ver o container que estava rodando, e usei o ``` docker exec -it containerID /bin/bash ```

• De dentro do Container:

- Atualizei os pacotes com ``` apt-get update``` e instalei o MySQL com o comando ```apt-get install default-mysql-client -y``` acessei o banco de dados com ``` mysql -h [ENDPOINTDORDS] -u [NomedoUsuárioPrincipal] -p ``` e estando dentro do banco de dados criei o database ``` create database wordpress``` para o o wordpress usar, __nas proximas instâncias que o auto scaling subir essas configurações não serão necessárias__.

• Configurando o Link (dns) do Load Balancers no wordpress:

- Acessando o Wordpress com o ip de uma das instâncias, no painel admin em configurações/geral nos campos Endereço Worpdress(URL) e Endereço do site(URL) veremos o IP que **deve ser substituidos pelo DNS do Load Balancer.**
![wordpresswrl](https://github.com/Gustavopedoni1/Projeto-CompassUOL-AWS_DOCKER/assets/157602238/398fae39-5b5d-4129-aa60-0ce18d6fa36a)
 
Caso não configure o Load Balancer vai mandar sempre para o mesmo Servidor, se o servidor cair perde a aplicação.


