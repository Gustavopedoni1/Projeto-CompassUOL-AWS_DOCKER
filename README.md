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
