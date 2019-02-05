# devops-tools-notes

# [nealalan.github.io](https://nealalan.github.io)/[devops-tools-notes](https://nealalan.github.io/devops-tools-notes)

## TOC
  - Machine Deployment - [Vagrant](https://nealalan.github.io/devops-tools-notes/#vagrant---vagrantupcom)
  - Machine Deployment - [Packer](https://nealalan.github.io/devops-tools-notes/#packer) & Cloud Init
    - [Using Packer to Create an AWS AMI](https://github.com/nealalan/devops-tools-notes/blob/master/README.md#using-packer-to-create-an-ami)
    - [Using Packer to Create and run a Docker Image](https://github.com/nealalan/devops-tools-notes/blob/master/README.md#using-packer-to-create-a-docker-image)
  - Configuration Management - [Puppet](https://nealalan.github.io/devops-tools-notes/#puppet) 
  - Configuration Management - [Chef](https://nealalan.github.io/devops-tools-notes/#chef)
  - Configuration Management - [Ansible](https://nealalan.github.io/devops-tools-notes/#ansible)
  - Configuration & Deployment - [Deploying to AWS with Ansible and Terraform](https://github.com/nealalan/devops-tools-notes/blob/master/README.md#deploying-to-aws-with-ansible-and-terraform)
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

## Deploying to AWS with Ansible and Terraform

### Deploying to AWS with Ansible and Terraform: Requirements
![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-02-04%20at%202.39.47%20PM.jpg?raw=true)
- a Private Hosted Zone which will have a CNAME to a database
- a Public Hosted Zone with a domain dev.domain to an EC2 bastion host and a www.domain with alias to ELB
- a wp_vpc (wordpress) with many subnets
  - 2 public subnets for high available web servers
  - 2 private subnets for EC2 instances with webservers the load balancer will pull from
  - 3 private subnets for RDS databasers
  - 2 route tables for public and private
  - 1 IGW
  - 4 SGs 
    - Private = All traffic, Source VPC IP Address
    - Public = port 80, Source 0.0.0.0/0
    - Dev = port 80 & 22, Source myIP
    - RDS = port 3306, Source Other Security Groups in VPC    
  - 1 S3 Private Endpoint so autoscaling instances can access Code Bucket repos without access to the internet

### Deploying to AWS with Ansible and Terraform: Budgeting
![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-02-04%20at%202.37.23%20PM.jpg?raw=true)
- Setup Billing: Budgets: Create Budget, set name, period, start and end date, budgeted amt, 
- THIS WILL ONLY NOTIFY YOU, NOT STOP ANYTHING
- Set Notifications!!!
- Note: When you run `$ terraform destroy' make sure it destroys the same number of resources that you created

### Deploying to AWS with Ansible and Terraform: Process Flow
![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-02-04%20at%202.45.17%20PM.jpg?raw=true)
- Dev server is created with WP
- Golden AMI is created to be used with launch configuration that deploys to autoscaling group
- Traffic to www.domain points to ELB, which accesses the autocaling group
- Code modified on dev env is forwarded to an S3 endpoint with a Code Bucket
- Script on the autoscaling instances pulls from the code bucket (set intervual) 
- All servers are able to access the private zone domain db.domain

### Deploying to AWS with Ansible and Terraform: Setup Process Overview
![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-02-04%20at%203.03.06%20PM.jpg?raw=true)
- Terraform will have admin priv in IAM
- Terraform builds the entire environment 
- Terraform calls an ansible playbook 
- Ansible provisions dev server using wordpress.yml
- Ansible creates Golden AMI for use by launch configuration to deploy instances to AG
- Developer access dev server via dev.domain
- Developer configures the db settings and connection
- Developer inidiates ansible to run the s3update.yml in dev env to deploy from dev to code bucket 
- Autoscaling Group will pull the code from Code Bucket to connect to the db
- Traffic to www.domain will now go to ELB to access the webserver that access the db

### Deploying to AWS with Ansible and Terraform: Setup Server
- Create a Ubuntu EC2 instance
```bash
$ sudo su -
$ python --version
$ apt update
$ apt install python-pip
$ pip install --upgrade pip
```

- Download terraform (can find the newest on the hashicorp site)
```bash
$ curl -O https://releases.hashicorp.com/terraform/0.11.2/terraform_0.11.2_linux_amd64.zip
$ mkdir /bin/terraform
$ unzip terraform* -d /bin/terraform
$ ls /bin/terraform
```

- Add terraform to the system path
```bash
$ terraform --version
# NOTE: Can't be found because not in the path
$ export PATH=$PATH:/bin/terraform
$ terraform --version
```

- Install AWS CLI
```bash
$ pip install awscli --upgrade
$ aws --version
$ apt update
```

- Install Ansible
```bash
$ apt install software-properties-common
# probably already installed
$ apt-add-repository ppa:ansible/ansible
$ apt udpate
$ apt install ansible
$ ansible --version
```

- Generate key to access server and add identity to ssh agent (MAY NEED TO RUN THIS AT EVERY LOGIN)
```bash
$ ssh-keygen
> /root/.ssh/kryptonite
$ ssh-agent bash
$ ssh-add ~/.ssh/kryptonite
$ ssh-add -l
```

- Modify Ansible Config
```bash
$ apt install nano
$ nano /etc/ansible/ansible.cfg
# DISABLE:
> host_key_checking = false
```

- Create working directory
```bash
$ mkdir terransible
$ cd terransible
```

### Deploying to AWS with Ansible and Terraform: Setup AWS IAM and DNS
- Setup what can't be setup with terraform 
- IAM: Add User: terransible; Programatic Access; Policy: Administrator Access; Create User; Download Credentials
- Route 53
  - Have a domain purchased. If you use a different Registrar you will need to do a few extras
- Log into server and setup creds 
  - Recommended creating profile 

```bash
$ sudo su - 
$ aws configure --profile terransible_lab
$ aws ec2 describe-instances --profile terransible_lab
# NOTE: may not have any instances listed
```

- Gather information for domain and create a Route53 Reusable Delegation Set
  - Copy, paste and same this to a local file
```bash
$ aws route53 create-reusable-delegation-set --caller-reference 1234 --profile terransible_lab
$ nano route53.nfo
> paste delegation set in
```
- Add delegation set to Route53
- Add/Edit Nameservers; Update

### Deploying to AWS with Ansible and Terraform: Setup Credentials and Variables
![](https://github.com/nealalan/devops-tools-notes/blob/master/images/Screen%20Shot%202019-02-04%20at%206.40.12%20PM.jpg?raw=true)
- Create files (two tf files for variables.
  - NOTE: make sure you add \*.tfvars to .gitignore
```bash
$ cd /home/user/terransible
$ touch main.tf terraform.tfvars variables.tf
$ touch userdata aws_hosts wordpress.yml s3update.yml
$ echo "provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}" > main.tf
$ echo "variable "aws_region" {}
variable "aws_profile" {}" > variables.tf
$ echo "aws_profile = "terransible_lab"
aws_region = "us-east-1"" > terraform.tfvars
```

### Deploying to AWS with Ansible and Terraform: Terraform Files
```bash
$ terraform init
$ terraform plan
```

### main.tf
```yml
provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#data "aws_availability_zones" "available" {}

#------------IAM---------------- 
# S3_access
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
  },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
}
EOF
}

#-------------VPC-----------

resource "aws_vpc" "wp_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "wp_vpc"
  }
}

#internet gateway

resource "aws_internet_gateway" "wp_internet_gateway" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  tags {
    Name = "wp_igw"
  }
}
# Route tables

resource "aws_route_table" "wp_public_rt" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wp_internet_gateway.id}"
  }

  tags {
    Name = "wp_public"
  }
}

resource "aws_default_route_table" "wp_private_rt" {
  default_route_table_id = "${aws_vpc.wp_vpc.default_route_table_id}"

  tags {
    Name = "wp_private"
  }
}

resource "aws_subnet" "wp_public1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_public1"
  }
}

resource "aws_subnet" "wp_public2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_public2"
  }
}

resource "aws_subnet" "wp_private1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_private1"
  }
}

resource "aws_subnet" "wp_private2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_private2"
  }
}

#create S3 VPC endpoint
resource "aws_vpc_endpoint" "wp_private-s3_endpoint" {
  vpc_id       = "${aws_vpc.wp_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = ["${aws_vpc.wp_vpc.main_route_table_id}",
    "${aws_route_table.wp_public_rt.id}",
  ]

  policy = <<POLICY
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
POLICY
}

resource "aws_subnet" "wp_rds1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_rds1"
  }
}

resource "aws_subnet" "wp_rds2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_rds2"
  }
}

resource "aws_subnet" "wp_rds3_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds3"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "wp_rds3"
  }
}

# Subnet Associations

resource "aws_route_table_association" "wp_public_assoc" {
  subnet_id      = "${aws_subnet.wp_public1_subnet.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_public2_assoc" {
  subnet_id      = "${aws_subnet.wp_public2_subnet.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_private1_assoc" {
  subnet_id      = "${aws_subnet.wp_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

resource "aws_route_table_association" "wp_private2_assoc" {
  subnet_id      = "${aws_subnet.wp_private2_subnet.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

resource "aws_db_subnet_group" "wp_rds_subnetgroup" {
  name = "wp_rds_subnetgroup"

  subnet_ids = ["${aws_subnet.wp_rds1_subnet.id}",
    "${aws_subnet.wp_rds2_subnet.id}",
    "${aws_subnet.wp_rds3_subnet.id}",
  ]

  tags {
    Name = "wp_rds_sng"
  }
}

#Security groups

resource "aws_security_group" "wp_dev_sg" {
  name        = "wp_dev_sg"
  description = "Used for access to the dev instance"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Public Security group

resource "aws_security_group" "wp_public_sg" {
  name        = "wp_public_sg"
  description = "Used for public and private instances for load balancer access"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  #HTTP 

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound internet access

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Private Security Group

resource "aws_security_group" "wp_private_sg" {
  name        = "wp_private_sg"
  description = "Used for private instances"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  # Access from other security groups

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#RDS Security Group
resource "aws_security_group" "wp_rds_sg" {
  name        = "wp_rds_sg"
  description = "Used for DB instances"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  # SQL access from public/private security group

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = ["${aws_security_group.wp_dev_sg.id}",
      "${aws_security_group.wp_public_sg.id}",
      "${aws_security_group.wp_private_sg.id}",
    ]
  }
}

#S3 code bucket

resource "random_id" "wp_code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket        = "${var.domain_name}-${random_id.wp_code_bucket.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "code bucket"
  }
}

#---------compute-----------

resource "aws_db_instance" "wp_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.6.27"
  instance_class         = "${var.db_instance_class}"
  name                   = "${var.dbname}"
  username               = "${var.dbuser}"
  password               = "${var.dbpassword}"
  db_subnet_group_name   = "${aws_db_subnet_group.wp_rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.wp_rds_sg.id}"]
  skip_final_snapshot    = true
}

#key pair

resource "aws_key_pair" "wp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

#dev server

resource "aws_instance" "wp_dev" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"

  tags {
    Name = "wp_dev"
  }

  key_name               = "${aws_key_pair.wp_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.wp_dev_sg.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id              = "${aws_subnet.wp_public1_subnet.id}"

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > aws_hosts 
[dev] 
${aws_instance.wp_dev.public_ip} 
[dev:vars] 
s3code=${aws_s3_bucket.code.bucket}
domain=${var.domain_name} 
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.wp_dev.id} --profile superhero && ansible-playbook -i aws_hosts wordpress.yml"
  }
}

#load balancer

resource "aws_elb" "wp_elb" {
  name = "${var.domain_name}-elb"

  subnets = ["${aws_subnet.wp_public1_subnet.id}",
    "${aws_subnet.wp_public2_subnet.id}",
  ]

  security_groups = ["${aws_security_group.wp_public_sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout             = "${var.elb_timeout}"
    target              = "TCP:80"
    interval            = "${var.elb_interval}"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "wp_${var.domain_name}-elb"
  }
}

#AMI 

resource "random_id" "golden_ami" {
  byte_length = 8
}

resource "aws_ami_from_instance" "wp_golden" {
  name               = "wp_ami-${random_id.golden_ami.b64}"
  source_instance_id = "${aws_instance.wp_dev.id}"

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF > userdata
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/' >> /var/spool/cron/root
EOF
EOT
  }
}

#launch configuration

resource "aws_launch_configuration" "wp_lc" {
  name_prefix          = "wp_lc-"
  image_id             = "${aws_ami_from_instance.wp_golden.id}"
  instance_type        = "${var.lc_instance_type}"
  security_groups      = ["${aws_security_group.wp_private_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  key_name             = "${aws_key_pair.wp_auth.id}"
  user_data            = "${file("userdata")}"

  lifecycle {
    create_before_destroy = true
  }
}

#ASG 

#resource "random_id" "rand_asg" {
# byte_length = 8
#}

resource "aws_autoscaling_group" "wp_asg" {
  name                      = "asg-${aws_launch_configuration.wp_lc.id}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace}"
  health_check_type         = "${var.asg_hct}"
  desired_capacity          = "${var.asg_cap}"
  force_delete              = true
  load_balancers            = ["${aws_elb.wp_elb.id}"]

  vpc_zone_identifier = ["${aws_subnet.wp_private1_subnet.id}",
    "${aws_subnet.wp_private2_subnet.id}",
  ]

  launch_configuration = "${aws_launch_configuration.wp_lc.name}"

  tag {
    key                 = "Name"
    value               = "wp_asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#---------Route53-------------

#primary zone

resource "aws_route53_zone" "primary" {
  name              = "${var.domain_name}.com"
  delegation_set_id = "${var.delegation_set}"
}

#www 

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.${var.domain_name}.com"
  type    = "A"

  alias {
    name                   = "${aws_elb.wp_elb.dns_name}"
    zone_id                = "${aws_elb.wp_elb.zone_id}"
    evaluate_target_health = false
  }
}

#dev 

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "dev.${var.domain_name}.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.wp_dev.public_ip}"]
}

#secondary zone

resource "aws_route53_zone" "secondary" {
  name   = "${var.domain_name}.com"
  vpc_id = "${aws_vpc.wp_vpc.id}"
}

#db 

resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.secondary.zone_id}"
  name    = "db.${var.domain_name}.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.wp_db.address}"]
}
```

#### variables.tf
```yml
variable "aws_region" {}
variable "aws_profile" {}
data "aws_availability_zones" "available" {}
variable "localip" {}
variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}

variable "db_instance_class" {}
variable "dbname" {}
variable "dbuser" {}
variable "dbpassword" {}
variable "key_name" {}
variable "public_key_path" {}
variable "domain_name" {}
variable "dev_instance_type" {}
variable "dev_ami" {}
variable "elb_healthy_threshold" {}
variable "elb_unhealthy_threshold" {}
variable "elb_timeout" {}
variable "elb_interval" {}
variable "asg_max" {}
variable "asg_min" {}
variable "asg_grace" {}
variable "asg_hct" {}
variable "asg_cap" {}
variable "lc_instance_type" {}
variable "delegation_set" {}

```

#### terraform.tfvars
```yml
localip       = "104.173.212.11/32"
aws_profile		= "terransible_lab"
aws_region		= "us-east-1"
vpc_cidr      = "10.0.0.0/16"
cidrs			= {
  public1  = "10.0.1.0/24"
  public2  = "10.0.2.0/24"
  private1 = "10.0.3.0/24"
  private2 = "10.0.4.0/24"
  rds1	   = "10.0.5.0/24"
  rds2     = "10.0.6.0/24"
  rds3     = "10.0.7.0/24"
}
db_instance_class	= "db.t2.micro"
dbname			= "superherodb"
dbuser			= "superhero"
dbpassword		= "superheropass"
key_name		= "kryptonite"
public_key_path		= "/root/.ssh/kryptonite.pub"
domain_name		= "bravethecloud"
dev_instance_type	= "t2.micro"
dev_ami			= "ami-b73b63a0"
elb_healthy_threshold   = "2"
elb_unhealthy_threshold = "2"
elb_timeout 		= "3"
elb_interval		= "30"
asg_max 		= "2"
asg_min			= "1"
asg_grace		= "300"
asg_hct			= "EC2"
asg_cap			= "2"
lc_instance_type	= "t2.micro"
delegation_set 		= "N1HDAZB52OQ3IV"
test = {}
```

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
