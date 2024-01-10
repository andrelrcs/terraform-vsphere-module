variable "vsphere_server" {
    description = "O servidor VCenter"
    default = "0.0.0.0"
    sensitive = true
}
variable "vsphere_user" {
    description = "Usuário Vcenter"
    type = string
    default = "user"
    sensitive = true
}
variable "vsphere_password" {
    description = "Senha do usuário"
    type = string
    default = "password"
    sensitive = true
}
variable "vsphere_dc" {
    description = "Data Center"
    type = string
    default = "DC"
}
variable "vsphere_datastore_name" {
    description = "Data Store"
    type = string
    default = "Data Store"
}

variable "vsphere_folder" {
  description = "Folder"
  type = string
  default = "datacenter/vm/folder"
}

#variable "vsphere_cluster" {}
variable "vsphere_resource" {
    description = "Pool"
    type = string
    default = "Pool"
}
variable "vsphere_rede" {
    description = "Nome Port Group da rede"
    type = string
    default = "rede"
}
variable "vsphere_qtd_hosts" {
    description = "Quantidade de instâncias"
    type = string
    default = "1"
}
variable "vsphere_namevm" {
    description = "Nome da máquina"
    default = "vm-name"
}
variable "vsphere_hostname" {
    description = "Hostname"
    default = "hostname"
}
variable "vsphere_domain" {
    description = "domain"
    type = string
    default = "seati"
}
variable "vsphere_ip" {
    description = "Endereço IP"
    default = "0.0.0.0"
}
variable "vsphere_ipmask" {
    description = "Máscara da rede"
    type = string
    default = "24"
}
variable "vsphere_gateway" {
    description = "Gateway"
    type = string
    default = "0.0.0.1"
}
variable "vsphere_dns_domain" {
    description = "domain"
    type = string
    default = "seati"
}
variable "vsphere_dns_server_list" {
    description = "Servers DNS"
}
variable "vsphere_cpus" {
    description = "Quantidade de vCPUs"
    default = "2"
}
variable "vsphere_memory_mb" {
    description = "Memória RAM"
    default = "2048"
}
variable "vsphere_disksize_gb"{
    description = "Tamanho do segundo disco"
    default = "30"
}
variable "vsphere_template" {
    description = "Template"
    type = string
    default = "Template"
}
