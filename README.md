# Configuring and Deploying Confluent with z/OS

Building streaming data pipelines involving data on a z/OS mainframe can be challenging. In this example we aim to automate and simplify provisioning and deployment of Z Development and Test (ZD&T) in AWS, along with Confluent Connect on Z.

## Repository Structure

The subdirectories in this repository are *provision*, *configure*, and *connect*. 
1. *Provision* includes utilities for provisioning ZD&T in AWS. 
1. *configure* provides tooling for installing Confluent Connect on Z on a target mainframe instance.
1. *connect* provides references for pointing Connect on Z to Confluent Cloud.

## Provisioning
Infrastructure.cf.yaml.IN is based on the IBM cloudformation template at ____ for spinning up ZD&T. We've made some modifications to make it work more smoothly in this example. Edit infrastructure.cf.yaml.IN to include your AMI, S3 bucket and your AWS keypair, then run cloudformation to invoke.

CLOUD_FORMATION_COMMAND

## Deploying Confluent

The shell scripts attempt to automate configuration and setup required to deploy Confluent to the mainframe. Since they're encoded differently we package them separately and copy them to the mainframe differently. 

### Binary Package

The binary package includes jar files and zip files constituting a Connect on Z deployment. The script generate-bin-package.sh arranges directories . To create:

1. Obtain the all client jar, connectors, and connect-on-Z and place them in bin-package.IN
1. Rub generate-bin-package.sh to create a directory structure of binaries to sftp over to the mainframe.

Copy the binary package to Z/OS as follows:

SFTP COMMAND

### Text Package

The text package includes shell scripts and configuration files customized for the z deployment and for Conflunet Cloud. The script generate-text-package.sh takes a completed env.sh file as input and generates the configuration files necessary for Connect-on-Z. Copy the text package to Z/OS as follows:

SCP COMMAND

## Running Connect on Z

From ZD&T, run 

CONNECT_STANDALONE_COMMAND
