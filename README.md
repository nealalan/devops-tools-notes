# devops-tools-notes

# [nealalan.github.io](https://nealalan.github.io)/[devops-tools-notes](https://nealalan.github.io/devops-tools-notes)

## TOC
  - Machine Deployment - [Vagrant]()
  - Machine Deployment - [Packer]()
  - Configuration Management - [Puppet]()
  - Configuration Management - [Chef]()
  - Configuration Management - [Ansible]()
  - Container Management - [Docker]() [Docker Compose]() [Docker Swarm]() [Docker Machine]()
  - Container Management - [Kubernetes]()
  - SW Eng - [Methodologies]()
  - SW Eng - [Jenkins]()
  - SW Eng - [GIT]()
  - SW Eng - [Prod Concepts]()
  
  
  
# Machine Delopyment

## Vagrant [vagrantup.com](https://www.vagrantup.com/docs/)

- Tool for building and managing virtual machine environments
- Allow single work flow for spinning up environments. Dev can mirror Prod.
- Machines provisioned on a provider (Docker, AWS, etc)

```bash
# set current directory to be a Vagrant environment and create a Vagrantfile
$ vagrant init

# Create and configure guest machines according to Vagrantfile
$ vagrant up

# Stop and destroy all resources
$ vagrant destroy

# make sure your vagrant file is valid
$ vagrant validate

#
$ vagrant provision

# runs a half and an up
$ vagrant reload

# status of machines in env
$ vagrant status

# connect
$ vagrant ssh
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
