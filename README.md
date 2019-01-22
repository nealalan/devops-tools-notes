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
- Vagrantfiles describes, configures, and provisions the machines you'll need.
- Available boxes: [https://app.vagrantup.com/boxes/search](https://app.vagrantup.com/boxes/search)


### Installing on a Mac

1. Can download from the hasicorp vagrantup site. DOWNLOAD: [https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)
2. use brew... I tried this method, however vagrant 2.0.0 had been previously installed and no longer works. But the system will not use the latest version. Tried uninstalling and deleting everything I can but still can't use the version installed with brew.

### Use on a Mac

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
- Additional Commands :
```bash
# make sure your vagrant file is valid
$ vagrant validate

$ vagrant provision

# runs a half and an up
$ vagrant reload
```

### Use Vagrant with Docker

1. Configure your [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile/). This will pull down a **ghost blog container** to run in docker and **map port 80** to 2368 on the counter
```bash
Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |d|
    d.image = "ghost"
    d.ports = ["80:2368"]
  end
end
```
2. Run vagrant
```bash
$ vagrant up
```
3. Find the docker container ID and connect to docker instance
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
$ vagrant ssh-config
```

### Provisioning using vagrant in the shell and w/ puppet

1. Clone Sample Vagrantfile: [https://github.com/linuxacademy/content-LPIC-OT-vagrant-puppet](https://github.com/linuxacademy/content-LPIC-OT-vagrant-puppet)
```bash
$ git clone https://github.com/linuxacademy/content-LPIC-OT-vagrant-puppet.git vagrant
```

2. Setup the vagrant file...
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

3. launch the webserver only
```bash
$ vagrant up web
```

4. Add provisioning to the Vagrantfile
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

5. relaunch what is up (only the web so far)
```bash
$ vagrant reload --provision
```

6. Add Puppet provider to the Vagrantfile
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

7. Validate for errors in Vagrantfile and launch the db server
```bash
$ vagrant validate
$ vagrant up db
```

8. Connect to the container and verify mysql is installed
```bash
# once server launches...
$ vagrant ssh db
$ sudo su
$ mysql
```

### Vagrant on CentOS Lab Notes

```bash
# check for docker
$ docker -v

# install vagrant - link from the downloads section
$ sudo yum install -y https://releases.hashicorp.com/vagrant/2.2.3/vagrant_2.2.3_x86_64.rpm
$ vagrant -v 

$ create Vagrantfile and map host port to vagrant port 80:2368
$ sudo yum install nano
$ nano Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |d|
    d.image = "ghost"
    d.ports = ["80:2368"]
  end
end

# launch and verify
$ sudo vagrant up
$ docker ps
$ docker images
$ curl http://localhost

# pull up web browser

```

### Use Vagrant and Docker to Build a DEV Env

1. Log into instance with Vagrant and Docker installed
2. Setup Dockerfile
```bash
$ sudo su
$ yum install nano
$ cd root/docker
$ nano Dockerfile

FROM node:alpine
COPY code /code
WORKDIR /code
RUN npm install
EXPOSE 3000
CMD ["node", "app.js"]
```

3. Setup Dockerfile
```bash
$ nano Vagrantfile

ENV['VAGRANT_DEFAULT_PROVIDER'] = "docker"

Vagrant.configure("2") do |config|
  config.vm.provider "docker" do |d|
    d.build_dir = "."
    d.ports = ["80:3000"]
  end
end
```

4. Use Vagrant to launch the Docker image "node:alpine"
```bash
$ mkdir code
$ vagrant validate
$ vagrant up

$ docker images
$ docker ps
```

5. see if the docker:alpine image port 3000 is mapped to localhost:80
```bash
$ curl localhost

```

6. to edit the js code... just cd into the code/ folder
```bash
$ vagrant reload
```

![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-01-18%20at%206.49.13%20PM.jpg?raw=true)

### Vagrant Box Files

- packaging format for vagrant 
- great for versioning changes, go back, fix a problem and rolls it out
- Download Vagrant Boxes: [https://app.vagrantup.com/boxes/search](https://app.vagrantup.com/boxes/search)

```bash
$ vagrant box add <ADDRESS>
$ vagrant box list
# tell you if box is outdated
$ vagrant box outdated
$ vagrant box outdated --global
# prune out old versions of boxes
$ vagrant box prune
$ vagrant box prune -n
# remove a specific box
$ vagrant box remove <NAME>
# repackage - reconstruct the box file
$ vagrant box repackage <NAME> <PROVIDER> <VERSION>
$ vagrant box repackage ubuntu64 virtualbox 0
# download and install the new box and you must update the individual running box
$ vagrant box update
$ vagrant box update --box centos/7 
# remove and readd box
$ vagrant box remove ubuntu64
$ vagrant box add ubuntu64
# automatically create the Vagrantfile for precise64
$ vagrant init hashicorp/precise64
```

### Creating a Vagrant Box file

1. Go into project folder "vagrant_box"
2. Download Ubuntu 18.04 using curl
3. Open virtual box and create a new box "ubuntu64-base, 512MB, 40GB, dynamic alloc
4. Disable audio, USB, set network port forwarding SSH 2222:22
5. Setup storage, CD-ROM, Virtual, vagrant_box, d/l file
6. Networking, set as NAT
7. Start machine in Virtual box, setup, add User: vagrant Pass: vagrant
8. Guided install for disk, automatically add security updates
9. Software Selection: OpenSSH Server, Basic Ubuntu Server, Yes for GRUB
10. Before restart, In Virtual Box: Eject the disk
11. Log into Ubuntu instance
12. Setup security
```bash
$ passwd root; vagrant
$ echo "vagrant ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers.d/vagrant
```
13. Get the vagrant public key: [https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub](https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub)
14. Get the key, setup SSH, install packages
```bash
$ mkdir /home/vagrant/.ssh
$ chmod 0700 /home/vagrant/.ssh
$ wget https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub
$ mv vagrant.pub authorized_keys
$ chmod 600 authorized_keys
$ chown -R vagrant ~/.ssh/
$ echo "AuthorizedKeysFile %h/.ssh/authorized_keys" | tee -a /etc/ssh/sshd_config
$ service ssh restart
$ apt install -y gcc build-essential git linux-headers-$(uname -r) dkms
```
15. VirtualBox Menu Bar: Devices: Insert Guest Additions CD image
```bash
$ mount /dev/cdrom /mnt
$ /mnt/VBoxLinuxAdditions.run
```
16. Compress all empty space out of filesystem
```bash
$ dd if=/dev/zero of=/EMPTY bs=1M
$ rm -f /EMPTY
```
17. Turn Ubuntu into a Vagrant Box from home OS to create a package.box
```bash
$ vagrant package --base ubuntu64-base

$ vagrant box add ubuntu64 package.box

$ vagrant box list
```
18. Run the new box and connect!
```bash
$ vagrant init ubuntu64 -m
$ cat Vagrantfile
$ vagrant up
$ vagrant ssh
```

### Box file format

- Can create a box file
- Can download a box file
- METADATA.JSON - lists metadata for box
- PACKAGE.BOX - box information file

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
