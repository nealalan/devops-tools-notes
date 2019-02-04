# devops-tools-notes

# [nealalan.github.io](https://nealalan.github.io)/[devops-tools-notes](https://nealalan.github.io/devops-tools-notes)

## TOC
  - Machine Deployment - [Vagrant](https://nealalan.github.io/devops-tools-notes/#vagrant---vagrantupcom)
  - Machine Deployment - [Packer](https://nealalan.github.io/devops-tools-notes/#packer) & Cloud Init
    - Using Packer to Create an AMI
    - [Using Packer to Create and run a Docker Image](https://github.com/nealalan/devops-tools-notes/blob/master/README.md#using-packer-to-create-a-docker-image)
  - Configuration Management - [Puppet](https://nealalan.github.io/devops-tools-notes/#puppet) 
  - Configuration Management - [Chef](https://nealalan.github.io/devops-tools-notes/#chef)
  - Configuration Management - [Ansible](https://nealalan.github.io/devops-tools-notes/#ansible)
  - Container Management - [Docker](https://nealalan.github.io/devops-tools-notes/#docker), [Docker Compose](https://nealalan.github.io/devops-tools-notes/#docker-compose), [Docker Swarm](https://nealalan.github.io/devops-tools-notes/#docker-swarm), [Docker Machine](https://nealalan.github.io/devops-tools-notes/#docker-machine)
  - Container Management - [Kubernetes](https://nealalan.github.io/devops-tools-notes/#kubernetes)
  - SW Eng - [Methodologies](https://nealalan.github.io/devops-tools-notes/#methodologies)
  - SW Eng - [Jenkins](https://nealalan.github.io/devops-tools-notes/#jenkins)
  - SW Eng - [GIT](https://nealalan.github.io/devops-tools-notes/#git)
  - SW Eng - [Prod Concepts](https://nealalan.github.io/devops-tools-notes/#prod-concepts)
  
## DEFINITIONS
- Vagrant = single work flow for spinning up environments
- Vagrant box = packaging format for vagrant 
- Packer = Create machine images for multiple platforms with a single custom config
- Cloud-init = Python scripts & Utils to handle early init of cloud instances
  
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
- Create machine images for multiple platforms with a single custom config
- Runs on all OS
- Create multiple images for multiple platforms in parallel 
- Works in parallel with shell scripts/Pupper/Chef (does not replace config mgmt tool)
- Don't make changes to a server, you must replace it


### Packer Templates
- Template are in JSON
- Template structure (array):
  - builders = what are we defining
  - description = what the template does
  - min_packer_version = optional
  - post-processors = what actions to take next (tagging or publishing to a repo)
  - provisioners = how are we going to configure the machine image
  - variables = pass in at run time of packer build

```bash
$ packer build
# bring a template up to date
$ packer fix
# learn what the template is doing (vars, definitions, etc)
$ packer inspect
# check syntax and config
$ packer validate
```

- Example builders: Amazon AMI, Azure, Docker, HyperV, OpenStack, VirtualBox, VMware
- Example provisioners: 
  - Ansible (Ansible local or Ansible remote = tranditional via SSH)
  - Chef (Chef Solo = locally)
  - File = upload files
  - PowerShell for Windows
  - Pupper (Pupper Master Server)
  - Shell = use shell command or scripts
- Post-processors:
  - Amazon Import = used to import to amazon and create an AMI
  - Checksum = post processor
  - Docker Push = Push to remote repo
  - Docker Tag 
  - Google Compute Image Exporter = create a tabball and upload to GC Storage
  - Shell = can execute shell scripts or inline
  - Vagrant
  - vSphere

### Install Packer

```bash
$ cd /usr/local/bin
$ wget <packer zip file>
$ yum install unzip
$ unzip <packer zip file>
$ rm <packer zip file>
$ cd
$ packer --version
```

### Create a Packer Template

```bash
$ mkdir packer
$ nano packer.json

{
  "variables": {
    "repository": "la/express",
    "tag": "0.1.0"
  },
  "builders": [
    { "type": "docker",
      "author": "<your name>",
      "image": "node",
      "commit": "true",
      "changes": [
        "EXPOSE 3000"
      ]
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "apt update && apt install curl -y",
        "mkdir -p /var/code",
        "cd /root",
        "curl -L https://github.com/linuxacademy/content-nodejs-hello-world/archive/v1.0.tar.gz -o code.tar.gz",
        "tar zxvf code.tar.gz -C /var/code --strip-components=1",
        "cd /var/code",
        "npm install"
        ]
    }
  ],
  "post-processors": [
    {
    "type": "docker-tag",
    "repository": "{{user `repository`}}",
    "tag": "{{user `tag`}}"
    }
  ]
}

$ packer validate
# fix errors
$ packer build -var 'tag=0.0.1' packer.json
$ docker images
# you will see any docker images from the past and this one
$ docker run -dt -p 80:3000 la/express:0.0.1 node /var/code/bin/www
$ docker ps
# you should see the docker image running
```

![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-01-21%20at%2010.40.22%20PM.jpg?raw=true)

### Cloud Init
- Python scripts & Utils to handle early init of cloud instances such as:
  - setting a default locale, an instance hostname
  - generating instance ssh private keys && adding to ~/.ssh/authorized_keys
  - set ephemeral mount points
  - configuring network devices
- Comes installed on: Ubuntu Cloud Images, Fedore, Devial, RHEL, CentOS  
  
```bash
$ cloud-init init = run by the OS but can be run on the CLI
$ cloud-init modules = activates modules using a config key
$ cloud-init single 
$ cloud-init dhclient-hook
$ cloud-init features = not always installed
$ cloud-init analyze = cloud-init logs and data
$ cloud-init devel = run the dev tools
$ cloud-init collect-logs = collect and tar debug info
$ cloud-init clean = remove logs and artifacts so cloud-init can re-run
$ cloud-init status = reports cloud-init status or wait on completion
```

- cloud-init works in 2 Formats: 
  1. GZIP, 
  2. mime multi-part archive
- script types  
  - User Data Script
  - Include Files
  - Cloud config data
  - Upstart job = content in /etc/init
  - Cloud Boothook = content in /var/lib/cloud
  - Part handler = custom code
- Example:
```bash
#!/bin/sh
echo "Hello World. The time is now $(date -R)!" | tee /root/output.txt
```
- See cloud-init modules: https://cloudinit.readthedocs.io/en/latest/topics/modules.html

### Using Packer to Create an AMI
- Use Cloud9 to create a Packer File that will create an AMI

- Install Packer on Cloud9 Server
  - AWS Console search Cloud9, Open IDE
  - Use the GUI console interface
  - Goto packer.io, Download, Copy the link
```bash
$ sudo su
$ cd /usr/local/bin
$ wget <packer.io link>
$ unzip pack*.zip
$ rm packer*.zip
$ exit
# packer --version
```

- Cloud9 GUI: File: Net File: packer.json
```json
{
  "variables": {
    "instance_size": "t2.small",
    "ami_name": "ami-make1up",
    "base_ami": "ami-from-AWS",
    "ssh_username": "ec2-user",
    "vpc_id": "",
    "subnet_id": ""
  },
  "builders": [
    {
      "type": "amazon-ebs",
      "region": "us-east-1",
      "source_ami": "{{user `base_ami`}}",
      "instance_type": "{{user `instance_size`}}",
      "ssh_username": "{{user `ssh_username`}}",
      "ssh_timeout": "20m",
      "ami_name": "{{user `ami_name`}}",
      "ssh_pty": "true",
      "vpc_id": "{{user `vpc_id`}}",
      "subnet_id": "{{user `subnet_id`}}",
      "tags": {
        "Name": "App Name",
        "BuiltBy": "Packer"
      }
    }
  ],
  "description": "AWS image",
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "sudo yum update -y",
        "sudo yum install -y git"
      ]
    }
  ]
} 
```

- In GUI prompt
```bash
$ packer validate
$ packer build -var 'ami_name=ami-make1up' -var 'base_ami=ami-1853ac65' -var 'vpc_id=' -var 'subnet_id=' packer.json
  ```
![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-01-22%20at%208.36.49%20PM.jpg?raw=true)

- Copy AMI-ID & Verify in EC2

![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-01-22%20at%208.40.26%20PM.jpg?raw=true)


### Using Packer to Create a Docker Image

1. In the root directory (of an instance), create a packerfile.json with the following contents:

```bash
$ sudo su -
```

  - Create a variable called repository, the default values should be la/express.
  - Create a variable called tag; the default values should be 1.0. 
  - It should use the Docker builder.
  - The type should be docker.
  - Set the author to use your name.
  - Use the node image.
  - Set commit to true.
  - In the changes setting, expose port 3000.
  - Create an inline shell provisioner. The provisioner will need to execute an apt-get update and install curl:

2. Create a directory call code in /var.
  - Use curl to download the application tar file to root: curl -L https://github.com/linuxacademy/content-nodejs-hello-world/archive/v1.0.tar.gz -o code.tar.gz
  - Untar the file to /var/code. tar zxvf code.tar.gz -C /var/code --strip-components=1
  - Go to /var/code and execute an npm install.
  
3. Create a docker-tag post-processor:
  - Set repository to use the repository variable.
  - Set tag to use the tag variable.

```bash

$ echo '{
  "variables": {
    "repository": "la/express",
    "tag": "0.1.0"
  },
  "builders": [
    { "type": "docker",
      "author": "<your name>",
      "image": "node",
      "commit": "true",
      "changes": [
        "EXPOSE 3000"
      ]
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "apt update && apt install curl -y",
        "mkdir -p /var/code",
        "cd /root",
        "curl -L https://github.com/linuxacademy/content-nodejs-hello-world/archive/v1.0.tar.gz -o code.tar.gz",
        "tar zxvf code.tar.gz -C /var/code --strip-components=1",
        "cd /var/code",
        "npm install"
        ]
    }
  ],
  "post-processors": [
    {
    "type": "docker-tag",
    "repository": "{{user `repository`}}",
    "tag": "{{user `tag`}}"
    }
  ]
}' > packerfile.json

```

4. Validate the packerfile.json.

```bash
$ packer validate packerfile.json
```

5. Build the docker image by Executing packer build.

```bash
$ packer build --var 'repository=la/express' --var 'tag=0.0.1' packerfile.json
# show the images that exist
$ docker images
```

6. Start a Docker container by executing: 

```bash
$ docker run -dt -p 80:3000 la/express:0.0.1 node /var/code/bin/www
# validate running
$ docker ps
$ curl localhost
```

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

# Pen Testing

## [Metasploit](https://www.metasploit.com/download)

- Pro versus Community - all the capabilities, not as pretty
  - https://github.com/rapid7/metasploit-framework/wiki/Nightly-Installers
- Possible to get using `$ vagrant up`






[[EDIT](https://github.com/nealalan/devops-tools-notes/edit/master/README.md)]
