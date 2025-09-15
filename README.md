# Playmobil

> [!IMPORTANT]
> ***This project is deprecated/obsoleted and won't work for new versions of Terraform/Ansible.***
>
> R.I.P 🪦

## O projeto

O nome do projeto foi inspirado na linha de brinquedos Playmobil, quando trabalhamos com *Infrastructure as Code (IAC)* vamos 'ligando' e 'encaixando' diversas partes para montar um ou mais 'cenários' diferentes, mas todos dentro da mesma temática: *cloud computing*.


>*Playmobil é uma linha de brinquedos criada por Hans Beck (1929 - 2009) em 1974 e vendida mundialmente a partir de 1975. A linha consiste em pequenos bonecos com partes móveis e uma série de objetos, veículos, animais e outros elementos com os quais esses bonecos irão se integrar compondo uma série de cenários, sempre dentro de uma temática específica*
>
>Fonte: [https://en.wikipedia.org/wiki/Playmobil](https://en.wikipedia.org/wiki/Playmobil)

A infraestrutura como código nos permite construir diversos ambientes, dos mais simples aos mais complexos, além da flexibilidade, agilidade e escalabilidade e segurança.

Com *Terraform* temos a flexibilidade de poder trabalhar com recursos de nuvem públicas e privadas, o que é de grande vantagem para quem trabalha com *multi-cloud*, gerenciar todas as nuvens com um único *framework*.

Se tratando de um projeto recente, a adoção da ferramenta vem se tornando cada vez mais frequente pelas empresas de internet, existe uma boa documentação no site oficial, e a comunidade é bem ativa contribuindo para o projeto. Isso gera *relases* com muita frequencia, corrigindo *bugs* e adicionando novos recursos.

## Pré Requisitos

- Acesso ao **Console AWS** com permissão *Administrator*.

- Terraform 0.9.11. [Download](https://releases.hashicorp.com/terraform/0.9.11/)

- Packer  1.0.4. [Download](https://www.packer.io/downloads.html)

## Definição dos arquivos

Arquivos e diretórios do projeto:

```README.md``` Este arquivo.

```ansible``` Diretório que contém *playbooks* e *roles* do Ansible.

```cf_terraform_setup.yml``` Template do *stack* Cloudformtion.

```instance_key``` Chaves pública e privada para acessar a instância (usuário ec2-user) caso seja necessário.

```packer_build_ami.json``` Template do Packer para criação da AMI customizada.

```terraform``` Diretório que contém os arquivos de provisionamento de toda a arquitetura na AWS.


## Composição do cenário
Do primeiro acesso ao console da AWS até o acesso final ao nosso site, serão necessários seguir alguns passos na ordem correta, são eles:


### Cloudformation
Primeiramente, é necessário preparar a conta AWS com alguns recursos necessários para rodar a automação pelo ***Terraform***, para isso será preciso criar um ***Stack*** no ***Cloudformation*** e importar o template ```cf_terraform_setup.yml```. 

Com esse *stack* criado, iremos criar a infraestrutura via ***Terraform*** em duas etapas, primeiro a **VPC** e em seguida todos os outros recursos usados pela aplicação **(security groups, auto scaling, load balancer etc...)**.

Esse template será responsável por:

- Criar um Bucket S3 Versionado para guardar os arquivos de estado do Terraform;
- Criar um usuário IAM;
- Criar um Access Key para esse usuário IAM. Isso irá permitir que o Terraform faça chamadas para a API da AWS;
- Criar uma IAM Role e uma IAM Policy com todas as permisões necessárias.

Após concluídos esses passos iniciais

### Terraform #1

Os códigos responsáveis pela criação da VPC estão dentro do diretório ```terraform/vpc/```, organizados de maneira a facilitar a manutenção seguindo o padrão ```service_resource.tf```

Com isso sabemos que o arquivo ```vpc/subnets.tf``` contém o código que irá criar as subnets, o arquivo ```vpc_nat_gateway.tf``` é responsável pela criação do Nat Gateway e assim por diante.

Além desses arquivos, existem alguns arquivos especiais que são:

- ```main.tf```: Contém as informações do *provider*;
- ```remote_state.tf```: Contém a configuração do *backend* de estado remoto;
- ```vars.tf```: Contém variáveis usadas no código, como região, cidr da VPC etc;
- ```outputs.tf```: Contém os *outputs* que o Terraform irá nos mostrar no final do processo.

Os arquivos nesse diretório irão provisionar:

- 1 VPC;
- 1 Internet Gateway;
- Nat Gateway;
- 1 EIP (usado pelo Nat Gateway;
- (2) Subnets públicas (com public DNS ativado);
- (2) Subnets privadas;
- 1 Route Table para subnet **pública** (com rota default para IGW);
- 1 Route Table para subnet **privada** (com rota default para Nat Gateway).


### Packer

O ***Packer*** que tem como papel criar uma **AMI customizada** com a aplicação configurada e pronta para rodar.

Essa decisão foi tomada com base na variação de acessos ao site, já que uma AMI customizada leva cerca de 2 minutos para ser inciada e entrar em produção, garantimos com isso agilidade na hora de escalar.

O Packer tem um único arquivos de configuração: ```packer_build_ami.json```, porém conta com outro parceiro para 'buildar' a image, o **Ansible**!

#### Ansible

O **Ansible** trabalha em conjunto com o *Packer* para provisionar a AMI customizada. 
Ele é responsável por configurar a instância com todos os serviços e pacotes necessários para rodar a aplicação.

Além disso, o Ansible também é o responsável por **baixar** o código mais recente do repositório e **configurar** a aplicação.

Os arquivos usados pelo ansible estão em ```ansible/```, os dois principais são:

- ```requirements.yml```: Usado pelo *Packer* para baixar todas as roles necessárias do Ansible Galaxy.
- ```setup.yml```: Playbook principal que o Packer irá usar para provisionar a imagem.


**Resumindo:** O Packer em conjunto com o Ansible serão responsáveis por:

- Criar uma instância temporária;
- Fazer a instalação dos pacotes necessários;
- Baixar o *source* da aplicação;
- Configuração e *Build* da aplicação;
- **Criar a AMI customizada** a partir da máquina provisionada.


### Terraform #2
A **criação da AMI customizada é extremamente necessária** para esse segundo passo com o ***Terraform***, pois ela irá provisionar a infraestrutura necessária para ter o site no ar.

Os arquivos que serão usados estão dentro do diretório ```terraform/app```, organizados da mesma maneira dos arquivos da **VPC.**

Esse passo será responsável por:

- Criar IAM Roles e IAM policys para a instancia;
- Importar uma *key pair* previamente criado para acesso a instancia (SE necessário);
- Criar o *Launch Configuration* com UserData definido no arquivo ```ec2_user_data_template.sh```;
- Criar o *Auto Scaling Group* com regras para escalar a aplicação e também notificações dos eventos gerados por ele;
- Criar um *Application Load Balancer* e um *Target Group*;
- Criar os *Security Groups* para a instancia e para o ALB com regras restritivas (o ALB irá aceitar conexões na porta 80 e a instancia só irá aceitar conexões recebidas do ALB na porta 8080);


## Criando o cenário


### Passo 1
Acesse o console AWS > Cloudformation e criar um novo stack com o template ```cf_terraform_setup.yml```.

Durante a criação será necessário preencher o campo **'TerraformBucketName'** com o nome do bucket que deseja criar.
Após concluído, na aba **'Output'** será exibido as credências de acesso que devem ser usadas para fazer as chamadas de API na conta.

Abra um terminal e exporte as variáveis.
Substitua pelo retorno que foi dado pelo Cloudformation:

```
export AWS_ACCESS_KEY_ID='<RESULTADO DA SAIDA ApiUserAccessKey>'
export AWS_SECRET_ACCESS_KEY='<RESULTADO DA SAIDA ApiUserSecretKey>'
```

Teste o acesso ao bucket:
```
aws s3 ls s3://tf-remote-123 --region us-east-2
```

**Nota:** Apenas será possível listar o bucket criado, nenhum outro bucket poderá ser acessado através dessas chaves.


### Passo 2

>***ATENÇÃO: A partir de agora todos os passos deverão ser executados em um único terminal, caso abra mais de um terminal, tenha certeza que exportou as variáveis com chave e senha de acesso da AWS feitos no Passo 1.***

Acesse o diretório ```terraform/vpc``` e edite os arquivos: ```remote_state.tf```

Troque o valor **\<BUCKET_NAME>** pelo nome do ***bucket*** criado pelo *CloudFormation*, se necessário altere a chave *'region'*

- **terraform/vpc/remote_state.tf**

```
terraform {
  backend "s3" {
    bucket  = "tf-remote-123"
    encrypt = "true"
    key     = "vpc/vpc.tfstate"
    region  = "us-east-2"
  }
}
```


### Passo 3
Acesse o diretório ```terraform/vpc``` e inicialize o *backend* remoto:

```
$ terraform init
```

Ao concluir, você deve ver a menssagem:

>***Terraform has been successfully initialized!***

Gere o plano de execução para verificar todos os recursos a serem criados:

```
$ terraform plan
```

Ao final, deve receber uma mensagem parecida com essa:

>***Plan: 14 to add, 0 to change, 0 to destroy.***

Isso significa que serão adicionados 14 novos recursos, e nenhum será modificado ou destruído.

Aplique o plano de execução:

```
$ terraform apply
```

O processo de criação demora alguns minutos, ao final você deve receber uma mensagem desse tipo:

>**Apply complete! Resources: 14 added, 0 changed, 0 destroyed.**
>
>The state of your infrastructure has been saved to the path
>below. This state is required to modify and destroy your
>infrastructure, so keep it safe. To inspect the complete state
>use the `terraform show` command.
>
>State path:
>
>Outputs:
>
>azs = us-east-2a,us-east-2b
>
>private_subnets = subnet-f8bee691,subnet-840164ff
>
>public_subnets = subnet-9ab1e9f3,subnet-8c0461f7


### Passo 4

Volte ao diretório raiz do projeto, edite o arquivo ```packer_build_ami.json``` e altere o valor ```<PUBLIC_SUBNET>``` com o valor de **apenas uma** subnet pública que foi dada pela saída do passo anterior.

- **packer\_build_ami.json**

````
 ...
    "subnet_id": "subnet-9ab1e9f3",
 ...
````

O valor do ```source_ami``` padrão (*ami-8a7859ef*) é referente ao último release da Amazon Linux AMI (*Amazon Linux AMI 2017.03.1 (HVM), SSD Volume Type*).

**Atenção:** Se a região for alterada, será necessário alterar também o ```source_ami```, pois o ```amiId``` é diferente de região para região. Consulte o ```ami_id``` referente a região usada.
 
Referência: [Finding a Linux AMI (english)](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html)

Execute o comando abaixo para iniciar a **criação da AMI customizada** já com a aplicação configurada.

```
$ packer build packer_build_ami.json
```

Nesse momento o Packer irá **criar uma instância temporária**, provisionar os serviços e pacotes necessários, baixar a aplicação do Git e fazer o 'build' da aplicação. Após conluído, o Packer irá **gerar uma AMI da instancia** e destruir os recursos temporários criados.

Quando terminado, será exibida uma mensagem do tipo:
>**Build 'amazon-ebs' finished.**
>
>==> Builds finished. The artifacts of successful builds are:
>--> amazon-ebs: AMIs were created:
>
>us-east-2: ami-dcbe9eb9

Note que o ami_id gerado foi ```ami-dcbe9eb9```.

### Passo 5

Após a criação da AMI, iremos 'montar' a última parte da nossa arquitetura.

Acesse o diretório ```terraform/app```, e como feito no **Passo 1**, troque o valor de ```<BUCKET_NAME>``` pelo nome do **bucket** criado pelo **CloudFormation** nos arquivos ```remote_state.tf``` e ```vars.tf```. Se necessário altere a chave ```region```.

- **terraform/app/remote_state.tf:**

```
terraform {
  backend "s3" {
    bucket  = "tf-remote-123"
    encrypt = "true"
    key     = "app/app.tfstate"
    region  = "us-east-2"
  }
}
```

Faça a mesma coisa com o arquivo ```vars.tf```:

- **terraform/app/vars.tf**

```
variable "bucket_name"  { default = "tf-remote-123" }
```

Repita os comando do passo 2 porém agora no diretório ```terraform/app``` : 


```
$ terraform init
$ terraform plan
$ terraform apply
```

Ao final, você deverá receber a seguinte mensagem:

>
>Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
>
>Outputs:
>
>Enjoy it! = alb-myinstance-1184002133.us-east-2.elb.amazonaws.com/en

Para acessar  aplicação, acesse a url informada. 

## Autoscaling

Inicialmente o *autoscaling* foi dimensionado para ter apenas 1 instância t2.micro, e no máximo 3.

Cada instancia roda com 2 threads do nodejs em modo *clustered*.

Os alames e as *triggers* de *scale up* e *scale down* foram dimensionadas a partir de testes de carga com o [Locust](http://locust.io).

#### Scale up

Adiciona 1 instancia caso a média de CPU do grupo de autoscaling atingir 45% por mais de 5 minutos consecutivos.

#### Scale down

Remove uma instância caso a média de CPU do grupo esteja abaixo de 15% por 10 minutos consecutivos. 
