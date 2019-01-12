# devops-tools-notes

# [nealalan.github.io](https://nealalan.github.io)/[devops-tools-notes](https://nealalan.github.io/devops-tools-notes)

## TOC
  - Machine Deployment - [Vagrant](https://nealalan.github.io/devops-tools-notes/#vagrant---vagrantupcom)
  - Machine Deployment - [Packer](https://nealalan.github.io/devops-tools-notes/#packer)
  - Configuration Management - [Puppet](https://nealalan.github.io/devops-tools-notes/#puppet)
  - Configuration Management - [Chef](https://nealalan.github.io/devops-tools-notes/#chef)
  - Configuration Management - [Ansible](https://nealalan.github.io/devops-tools-notes/#ansible)
  - Container Management - [Docker](https://nealalan.github.io/devops-tools-notes/#docker), [Docker Compose](https://nealalan.github.io/devops-tools-notes/#docker-compose), [Docker Swarm](https://nealalan.github.io/devops-tools-notes/#docker-swarm), [Docker Machine](https://nealalan.github.io/devops-tools-notes/#docker-machine)
  - Container Management - [Kubernetes](https://nealalan.github.io/devops-tools-notes/#kubernetes)
  - SW Eng - [Methodologies](https://nealalan.github.io/devops-tools-notes/#methodologies)
  - SW Eng - [Jenkins](https://nealalan.github.io/devops-tools-notes/#jenkins)
  - SW Eng - [GIT](https://nealalan.github.io/devops-tools-notes/#git)
  - SW Eng - [Prod Concepts](https://nealalan.github.io/devops-tools-notes/#prod-concepts)
  
  
  
# Machine Delopyment

## Vagrant - [vagrantup.com](https://www.vagrantup.com/docs/)

- Tool for building and managing virtual machine environments
- Allow single work flow for spinning up environments. Dev can mirror Prod.
- Machines provisioned on a provider (Docker, AWS, etc)

### Install (Mac)

Can download from the hasicorp sites or use brew...

```bash
$ brew install vagrant-completion
# OR
$ brew upgrade vagrant-completion

$ vagrant -v
```

I tried this method, however vagrant 2.0.0 had been previously installed and no longer works. But the system will not use the latest version. Tried uninstalling and deleting everything I can but still can't use the version installed with brew.

DOWNLOAD: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

### About Vagrantfiles

A file that describes, configures, and provisions the machines you'll need.

### Use (Mac)

0. Install the latest version of [VirtualBox](https://www.virtualbox.org/wiki/Downloads). I had a version that was out of date and would no longer run on MacOS.

1. Creating a vagrant file...
```bash
# set current directory to be a Vagrant environment and create a Vagrantfile
#   within ~/Projects/vagrant/
$ vagrant init
```
2. Edit vagrant file
```bash
$ atom ~/Projects/vagrant/Vagrantfile
```
3. Bring up vagrant
```bash
# Setup environment Create and configure guest machines according to Vagrantfile
$ vagrant up
# ALSO:
$ vagrant up --PROVIDER=VirtualBox --debug
```
4. See machine running
```bash
# status of machines in env
$ vagrant status
```
5. connect to the machine instance
```bash
# connect
$ vagrant ssh default
```
6. stop and destroy the machine (all resources)
```bash
$ vagrant destroy
```


ALSO:
```bash
# make sure your vagrant file is valid
$ vagrant validate
#
$ vagrant provision
# runs a half and an up
$ vagrant reload
```

### Use (docker) and [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile/)

```bash
Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |d|
    d.image = "ghost"
    d.ports = ["80:2368"]
  end
end
```
- Pull down a container ghost blog and run in docker.
- Map port 80 to 2368 on the counter

```bash
$ docker ps

$ docker exec -i -t [container-id] /bin/bash
```





## Packer 


# Configuration Management

## Puppet


## Chef


## Ansible


# Container Management 

## Docker

## Docker Compose

## Docker Swarm

## Docker Machine

## Kubernetes


# SW Eng
  
## Methodologies
 
## Jenkins

## GIT

## Prod Concepts



[[EDIT](https://github.com/nealalan/devops-tools-notes/edit/master/README.md)]
