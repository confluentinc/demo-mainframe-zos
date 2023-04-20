# Configuring and Deploying Confluent with z/OS

Building streaming data pipelines involving data on a z/OS mainframe can be challenging. In this example we aim to automate and simplify provisioning and deployment of Z Development and Test (ZD&T) in AWS, along with Confluent Connect on Z.

## Repository Structure

The subdirectories in this repository are *provision*, *configure*, and *connect*. 
1. **provision** shows steps and provides utilities for provisioning ZD&T in AWS. 
1. **configure** includes tooling for installing Confluent Connect on Z on a target mainframe instance.
1. **connect** provides references for pointing Connect on Z to Confluent Cloud.

## PROVISION: Create Z/OS instance and install ZD&T in AWS
Infrastructure.cf.yaml.IN is based on the IBM cloudformation template at ____ for spinning up ZD&T. We've made some modifications to make it work more smoothly in this example. Edit infrastructure.cf.yaml.IN to include your AMI, S3 bucket and your AWS keypair, then run cloudformation to invoke.

    aws cloudformation deploy --template-file ./infrastructure.cf.yaml --stack-name name-of-stack --capabilities CAPABILITY_IAM

## CONFIGURE: Install and Configure Connect on Z

The shell scripts attempt to automate configuration and setup required to deploy Confluent to the mainframe. Since they're encoded differently we package them separately and copy them to the mainframe differently. 

### Binary Package

The binary package includes jar files and zip files constituting a Connect on Z deployment. The script generate-bin-package.sh arranges directories . To create:

1. Obtain the all client jar, connectors, and connect-on-Z and place them in bin-package.IN
1. Rub generate-bin-package.sh to create a directory structure of binaries to sftp over to the mainframe.

Copy the binary package to Z/OS as follows:

    sftp -P 2022 ibmuser@34.222.94.162
    mkdir cflt-zos
    cd cflt-zos
    put -r bin-package

### Text Package

The text package includes shell scripts and configuration files customized for the z deployment and for Conflunet Cloud. The script generate-text-package.sh takes a completed env.sh file as input and generates the configuration files necessary for Connect-on-Z. Copy the text package to Z/OS as follows:

    scp -P -r text-package ibmuser@34.222.94.162:~/cflt-zos

## CONNECT: Running Connect on Z to Connect to Confluent Cloud

From ZD&T, run 

    export LIB_PATH=$LIB_PATH:path_to_lib
    
    ./connect-standalone ../etc/kafka/connect-standalone.properties ../etc/kafka/mq-source.properties

