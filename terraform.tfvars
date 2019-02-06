# LOCAL IP IS YOUR SYSTEM PUBLIC IP ADDRESS
#  curl ifconfig.co
localip       = "192.168.0.1/32"
aws_profile		= "terransible_lab"
aws_region		= "us-east-1"
vpc_cidr      = "10.0.0.0/16"
# SUBNET CIDRS ARRAY
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
dbname			= "terransible_lab_db"
dbuser			= "terransible_lab"
dbpassword		= "terransible_lab_pass"
key_name		= "kryptonite"
public_key_path		= "/root/.ssh/kryptonite.pub"
domain_name		= "terransible_lab"
dev_instance_type	= "t2.micro"
dev_ami			= "ami-b73b63a0"
# ELASTIC LOAD BALANCER VARS
#  set as low as possible
elb_healthy_threshold   = "2"
elb_unhealthy_threshold = "2"
elb_timeout 		= "3"
elb_interval		= "30"
# AUTOSCALING GROUP VARS
lc_instance_type	= "t2.micro"
asg_max 		= "2"
asg_min			= "1"
# health check grace period time
asg_grace		= "300"
# health check type - if not running, will be destroyed
asg_hct			= "EC2"
asg_cap			= "2"
delegation_set 		= ".... from route53 file ..."
test = {}
