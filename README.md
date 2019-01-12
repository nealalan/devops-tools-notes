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

- **Tool for building and managing virtual machine environments**
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

Available boxes: [https://app.vagrantup.com/boxes/search](https://app.vagrantup.com/boxes/search)

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

### Mapping files

- Map the local file (in the host vagrant file folder) to the folder on the virtual machine
```bash
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder ".", "/vagrant"
end
```
### Connecting to vagrant with SSH
- Use SSH versus VAGRANT SSH to connect from the localhost to vagrant

```bash
$ ssh vagrant@localhost -p 2222 -i ~/.vagrant.d/insecure_private_key
```

- default password is vagrant
- to get the info from vagrant...

```bash
$ vagrand ssh-config
```

### Provisioning in the shell and w/ puppet

- Sample Vagrantfile: [https://github.com/linuxacademy/content-LPIC-OT-vagrant-puppet](https://github.com/linuxacademy/content-LPIC-OT-vagrant-puppet)
- Clone: 
```bash
$ git clone https://github.com/linuxacademy/content-LPIC-OT-vagrant-puppet.git vagrant
```

Setup the vagrant file...
```bash
Vagrant.configure("2") do |config|
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/trusty64"
    web.vm.hostname = "web.vagrant.vm"
  end
  
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/trusty64"
    db.vm.hostname = "db.vagrant.vm"
  end
end
```

- launch the webserver only
```bash
$ vagrant up web
```

- Add provisioning to the Vagrantfile
```bash
Vagrant.configure("2") do |config|
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/trusty64"
    web.vm.hostname = "web.vagrant.vm"
    web.vm.provision "she;;" do |shell|
      shell.inline = "apt update -y
      shell.inline = "apt install apache2 -y"
    end
  end
  
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/trusty64"
    db.vm.hostname = "db.vagrant.vm"
  end
end
```

- relaunch
```bash
$ vagrant reload --provision
```

- Add Puppet provider to the Vagrantfile
```bash
Vagrant.configure("2") do |config|
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/trusty64"
    web.vm.hostname = "web.vagrant.vm"
    web.vm.provision "she;;" do |shell|
      shell.inline = "apt update -y
      shell.inline = "apt install apache2 -y"
    end
  end
  
  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/trusty64"
    db.vm.hostname = "db.vagrant.vm"
    db.vm.provision "puppet" do |puppet|
      puppet.manifest_path = "puppet/manifests"
      puppet.manifest_file = "default.pp"
      puppet.module_path = "puppet/modules"
      puppet.hiera_config_path = "puppet/hiera.yaml"
    end
  end
end
```

- ensure we didn't create any errors in the Vagrantfile
- launch the db server
```bash
$ vagrant validate
$ vagrant up db
# once server launches...
$ vagrant ssh db
$ sudo su
$ mysql
```

- mysql is installed


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
