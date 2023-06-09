# Provisioning ZD&T

This example uses AWS Cloudformation to provision a License Server and Enterprise
Server for ZD&T. 

This is based on the example from IBM at:
https://github.com/aws-samples/mainframe-ibm-zdt-zos-aws

ZD&T Docs are available here:

https://www.ibm.com/docs/en/zdt/13.3.x?topic=enterprise-edition-v1334.

However we have updated it to allow for configurabilty of AMI, region, S3 bucket name, and so on. 

## Prerequisites:

### Install packages
Download the installation packages for ZD&T at: 

https://www.ibm.com/docs/en/zdt/13.3.x?topic=v1334-downloading-installation-packages

And place them in an AWS bucket, noting the name.

### Keypair
Generate a keypair either from the AWS UI or from the command line:

example:

    aws ec2 create-key-pair --key-name mainframe-cflt --query "KeyMaterial" --output text > mainframe-cflt.pem

### Cloudformation Template
Edit the cloudformation template at `infrastructure.cf.yaml.IN` to insert your AWS region, keypair, S3 bucket, installer unpacked name, and the default image for ADCD. You can also specify the zdtadmin username and password here. Search for `YOUR` to find elements needing customization in this file.

### Deploy Enterprise Server and License Server
Now run CloudFormation to deploy:

    aws cloudformation deploy --template-file ./infrastructure.cf.yaml --stack-name jwfbean-zdt --capabilities CAPABILITY_IAM

At the conclusion of the deployment you have an enterprise server and a 
license server. You know this is running because the license server is
writes a license file to the s3 bucket at the conclusion of installation.

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

Default login is `zdtadmin`/`password`

This should get you to the ZDT admin page documented at:

https://github.com/aws-samples/mainframe-ibm-zdt-zos-aws

### Provisioning a Target Server

The next step is to provision a target server, also known as an "emulator
server". 

In this example, we provisioned an ec2 instance as follows:

 - ami-06f03a76f0e5faeb4 
 - m5.2xlarge 
 - Same VPC as Enterprise and License Server
 - Same ec2 security group as Enterprise and License Server
  - Add 500GB external   storage

Accommodate the ZD&T TCP/IP Ports::

 - 8082-8083 
 - 2022-2023 
 - 20-23 

### Creating an ZD&T Image
While this is provisioning you can go to the web UI, configure an image
with at least:

 - z/OS 
 - IBM MQ

### Prepare target host
ssh to the target host as `ec2-user` and prepare the host. The following
steps are required for ZD&T installation:

    sudo groupadd zpdt
    sudo usermod -a -G zpdt ec2-user
    sudo yum install unzip
    sudo yum install nc
    sudo yum install iptables
    sudo yum install ftp

Lastly, Deploy the image from the UI.

### Confirm a running ZD&T
To confirm operational Z/OS, use Mocha or a TN3720 emulator to make
a connection to the mainframe. 

 - Login 
 - Select MQ Series (option 11)
 -  View queue (Queue manager CSQ9, List or Display, Queue Name *)

### Adding Storage

These commands will add storage:

 - sudo yum install python38
 -  sudo yum install
 -  git git clone https://github.com/stan-confluent/zPDT_Pub

#### Stop ZD&T
To stop zos:
[ec2-user@ip-10-0-0-24 zPDT_Pub]$ ./stopZos -noverify

#### Resize Volume
mkdir /home/ec2-user/zdt/cards
mkdir /home/ec2-user/zdt/print
./zdtVresize -i A5USR1 -s 54 -d /home/ec2-user/zdt/volumes

Then restart ZD&T from the UI.

### Useful Tricks:

You can also ssh to the mainframe at the target host on port 2022. Once there you have a terminal but it can be wonky. 

    Your TERM environment likely outdates Z/OS. Try
    export TERM=xterm 

Use iconv to correct misencodings. Give it a shot.

Different file transfer tools will If you use `sftp` for binaries, `scp` for text files, they will encode correctly.

To confirm correct encoding, you can use the file command to obtain the document type. Vague types like `binary data` likely indicate misencoding.
