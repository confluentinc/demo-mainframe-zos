# Provisioning ZD&T

This example uses Cloudformation to provision a License Server and Enterprise
Server for ZD&T. ZD&T Docs are available here:

https://www.ibm.com/docs/en/zdt/13.3.x?topic=enterprise-edition-v1334.

It is based on the example from IBM at:
https://github.com/aws-samples/mainframe-ibm-zdt-zos-aws

However we have updated it to include a different AMI for RHEL so that
yum commands etc execute properly. We also modified it to refer to a specific
installer name from the s3 bucket.

## Prerequisites:
### Install packages
Download the isntallation packages for ZD&T at: 

https://www.ibm.com/docs/en/zdt/13.3.x?topic=v1334-downloading-installation-packages

And place them in an AWS bucket.

### Keypair
Generate a keypair either from the AWS UI or from the command line:

example:

aws ec2 create-key-pair --key-name mainframe-cflt --query "KeyMaterial" --output text > mainframe-cflt.pem

### Cloudformation Template
Edit the cloudformation template to insert your AWS region, keypair, S3 bucket, installer unpacked name, and the default image for ADCD.

### Deploy Enterprise Server and License Server
Now run CloudFormation to deploy:

aws cloudformation deploy --template-file ./infrastructure.cf.yaml --stack-name jwfbean-zdt --capabilities CAPABILITY_IAM

At the conclusion of the deployment you have an enterprise server and a 
license server. You know this is running because the license server is
writes a license file to the s3 bucket.

### Licensing

The license file looks like this:
ip-x-x-x-xxx_yyyyyyyyyy.zip

Take the license file and use it to obtain a license from IBM. The license
they give you will be in the form:

ip-x-x-x-x_yyyyyyyyyy_update.zip

When you place that file in the s3 bucket, a file should appear noting that the license has been applied.

### Enterprise Server UI

When the license is applied, you're ready to go. Go to this URL to access
the enterprise server:

https://public-hostname:9443/ZDTMC/

username zdtadmin
password password

This should get you to the ZDT admin page documented at:

https://github.com/aws-samples/mainframe-ibm-zdt-zos-aws

### Provisioning a Target Server

The next step is to provision a target server, also known as an "emulator
server". 

In this example, we provisioned an ec2 instance as follows:

ami-06f03a76f0e5faeb4
m5.2xlarge
Same VPC as the others
jwfbean-zdt-target
Use the same ec2 security group
Add 500GB external storage

Other ports you want open include:
8082-8083
2022-2023
20-23
9443

### Creating an ZD&T Image
While this is provisioning you can go to the web UI, configure an image
with:
z/OS
IBM MQ

### Prepare target host
Return to the target host and install some commands. The following
commands are used by the enterprise server to place ZD&T on the host
sudo groupadd zpdt
sudo usermod -a -G zpdt ec2-user
sudo yum install unzip
sudo yum install nc
sudo yum install iptables
sudo yum install ftp

Lastly, Deploy the image.

### Confirm a running ZD&T
To confirm operational Z/OS, use Mocha or a TN3720 emulator to make
a connection to the mainframe. 

Login
Select MQ Series (option 11)
View queue (Queue manager CSQ9, List or Display, Queue Name *)

### Adding Storage

These commands will add storage:
sudo yum install python38
sudo yum install git
git clone https://github.com/stan-confluent/zPDT_Pub

#### Stop ZD&T
To stop zos:
[ec2-user@ip-10-0-0-24 zPDT_Pub]$ ./stopZos -noverify

#### Resize Volume
mkdir /home/ec2-user/zdt/cards
mkdir /home/ec2-user/zdt/print
./zdtVresize -i A5USR1 -s 54 -d /home/ec2-user/zdt/volumes



### Useful Tricks:

You can also ssh to the mainframe at the target host on port 2022:

export TERM=xterm 
iconv can correct misencodings
If you use sftp for binaries, scp for text files, they will encode correctly.
use file command to confirm document type

