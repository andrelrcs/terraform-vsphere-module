# terraform-vsphere-module
![VMware](https://img.shields.io/badge/VMware-231f20?style=for-the-badge&logo=VMware&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)![Cent OS](https://img.shields.io/badge/cent%20os-002260?style=for-the-badge&logo=centos&logoColor=F0F0F0)![Red Hat](https://img.shields.io/badge/Red%20Hat-EE0000?style=for-the-badge&logo=redhat&logoColor=white)

Modulo Terraform voltado para o vCenter.

### Preparando o template
Primeiramente é preciso preparar um template de máquina virtual no vCenter. 

Para isso, será criada uma máquina normal, levando em conta os seus padrões de particionamento e segurança.

Em seguida, deverá ser o utilizado um [script de formatação de vm](https://github.com/fabianlee/tf-vsphere-singlevm-from-template/blob/main/on_template_only/prepare-ubuntu-22.04-template.sh), que irá limpar informações como IP, hostname e histórico e deixar a máqina pronta para ser desligada e transformada em Template.

> Basta criar um arquivo na maquina com a extensão '.sh', adicionar o conteúdo do link acima e transformá-lo em executável da seguinte forma: "chmod +x nome_script.sh". Em seguida, execute-o "./nome_script.sh".

Após desligar a máquina, no vCenter vá na aba *Hosts and Clusters* -> clique no botão direito no nome da máquina -> *Template* -> *Convert to Template*.

### Preparando as credenciais Terraform
Por questões de segurança, as suas credenciais e endereço do VCenter não devem ser adicionadas diretamente no código.

Para isso será utilizada a ferramenta Pass para encriptar suas credenciais.

Instale o Pass:
```bash
sudo apt install pass -y
```

Instale o comando gpg2
```bash
sudo apt install gnupg2 -y
```

Configure uma GPG key :
```bash
gpg2 --gen-key
```
Escolha um nome para a chave e em seguida pedirá para escolher uma senha para esta chave.

> Atenção: esta não é a senha a ser armazenada.

Liste a chave criada para encontrar o ID da chave:
```bash
gpg2 --list-secret-keys
```

A saída será da seguinte forma:
```hcl
   gpg: key BD8C6DC45B4BD264 marked as ultimately trusted
   gpg: directory '/root/.gnupg/openpgp-revocs.d' created
   gpg: revocation certificate stored as '/root/.gnupg/openpgp-revocs.d/19FE295FBA0232251519F824BD8C6DC45B4BD264.rev'
   public and secret key created and signed.

   pub   rsa4096 2023-06-15 [SC]
         19FE295FBA0232251519F824BD8C6DC45B4BD264   ---> ID da chave (GPG-KEY-ID)
   uid                      Password
   sub   rsa4096 2023-06-15 [E]                   
```

Configure o Pass com o seguinte comando adicionando o ID da chave encontrado no comando anterior.
```bash
pass init ID-DA-CHAVE
```
 
(Exemplo: `pass init 19FE295FBA0232251519F824BD8C6DC45B4BD264`)

> Isso irá criar o diretório do password-store directory, por default fica em ~/.password-store/. 

Adicionar as credenciais utilizando o pass insert

Exemplo:
```hcl
pass insert usuario
Enter password for usuario: terraform

pass insert senha
Enter password for senha: pass123

pass insert server
Enter password for server: 192.168.0.2
```

> Atenção: Quando for criar o "pass" do usuário, mesmo que apareça "Enter password for ..." deverá ser inserido o seu usuário e não a senha dele.

Passar os valores encriptados pelo Pass para uma variável de ambiente do terraform:
```bash
export TF_VAR_vsphere_user=$(pass usuario)
export TF_VAR_vsphere_password=$(pass senha)
export TF_VAR_vsphere_server=$(pass server)
```

> Quando rodar o terraform apply as credenciais serão identificadas automaticamente.

### Módulos
O Terraform trabalha com módulos, que como em uma linguagem de programação qualquer, são basicamente “funções”, que processam um ou alguns “resources” em conjunto e evita a repetição de código.

Qualquer arquivo de configuração Terraform (`.tf`) em um diretório, mesmo que seja apenas um, forma um módulo.

Quando um arquivo de configuração está utilizando outros arquivos de configuração, este então é chamado de **root module (módulo raiz)** e os arquivos utilizados são **child modules (módulos filhos)**.

Neste projeto se constitui do módulo filho com um arquivo `main.tf` e `variables.tf`, que será chamado no arquivo `main.tf` do módulo raiz que será criado seguindo o exemplo abaixo.


### Utilizando o Terraform
Neste Framework, o módulo filho gera novas máquinas a partir da clonagem de templates pré-configurados no arquivo `main.tf` e declara todas as variáveis em `variables.tf`. 

O módulo root iniciará o terraform, se conectará ao provedor (*provider*) *vsphere*, chamará o módulo filho a partir da variável *source* e definirá todas as variáveis.

Abaixo, um exemplo de módulo root.

```hcl
terraform {
  required_version = ">= 0.14.7"
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
}

variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}

provider "vsphere" {
    user                    = var.vsphere_user
    password                = var.vsphere_password
    vsphere_server          = var.vsphere_server #Endereço do servidor VCenter
    allow_unverified_ssl    = true
}

module "modulo_create_vm" {
    source                  = "XXXXXX" #Caminho da child module
    vsphere_dc              = "XXXXX-XX" #Data Center
    vsphere_datastore_name  = "XX_XXXXX_XXXX" #Storage
    vsphere_folder          = "XXXXX/XXXX" #Pasta
    vsphere_resource        = "XXXXX" #Resource Pool
    vsphere_rede            = "xxxx" #Nome da portgroup (rede da maquina)
    vsphere_qtd_hosts       = "x" #Número de máquinas
    vsphere_cpus            = "x" #Número de vCPUs
    vsphere_memory_mb       = "xxxx" #Tamanho de Memória RAM em MBs (apenas o numero) (Ex: 2GB = 2048)
    vsphere_disksize_gb     = "XX" #Tamanho do HD extra em GBs (mínimo 40)
    vsphere_template        = "xxxxxxx" #Nome do Template a ser clonado (Padrão: Template UBUNTU 22.04.3 LTS )

    vsphere_namevm          = ["xxxx"] #Nome da máquina no VCenter.(Para mais de uma máquina será: ["xxx1", "xxx2"])
    vsphere_hostname        = ["xxxx"] #Hostname no sistema (lembrete, o linux não aceita "." no hostname) (Para mais de uma máquina será: ["xxx1", "xxx2"])

    vsphere_domain          = "vcenter.local" #Dominio da maquina
    vsphere_ip              = ["XXX.XXX.XXX.XXX"] #IP da máquina (Para mais de uma máquina será: ["XXX.XXX.XXX.XX2", "XXX.XXX.XXX.XX3"])
    vsphere_ipmask          = "xx" #CIDR da rede (Ex: Para máscara 255.255.255.0 o CIDR é 24) 
    vsphere_gateway         = "172.16.2.254" #IP do gateway
    vsphere_dns_domain      = "domain.local"
    vsphere_dns_server_list = ["XXX.XXX.XXX.XXX", "XXX.XXX.XXX.XXX"] #Endereços de DNS

}

resource "null_resource" "module_guardian" {
  lifecycle {
    prevent_destroy = true  #Para proteger a máquina de exclusões acidentais. Quando estiver em true, não será possível excluí-la pelo terraform destroy. 
  }
}

output "UUID" {
  value = module.modulo_create_vm #Printar valor do UUID da máquina para documentação
}

```
Crie uma pasta para a sua root module e crie o arquivo `main.tf` com as informações no formato das citadas acima.

A variável `source` se refere à localização do modulo filho, podendo ser tanto uma pasta local, como um repositório remoto.

Módulo em pasta local:

```hcl
  source                  = "../../../Terraform/Modulo/server_comum"
```

Módulo em repositório remoto:

```hcl
source                  = "git::https://github.com/andrelrcs/terraform-vsphere-module.git"
```

> A recomendação é que utilize o repositório remoto para sempre estar com a versão mais recente do módulo.

Ao salvar e fechar o arquivo `main.tf` insira o comando para iniciar o Terraform e carregar os provedores:

```bash
terraform init
```

Se tudo iniciar corretamente, prossiga com o comando:
```bash
terraform plan
```

Revise as informações. E, se não houver erros, faça o comando:
```bash
terraform apply
```

No final, irá perguntar se as informações estão corretas e se deseja continuar, se sim, digite `yes`.

Ao finalizar o processo, um output informará o UUID da nova máquina:

```bash
Outputs:

UUID = {
  "vm_uuid" = "43355bdf-7b5a-1dc6-2f19-e2b1def3c081"
}
```