#!/usr/bin/python3

# This script creates the keypair file which will be used to create and access the ec2 instance. 
# Then it spin up the ec2 instance and calls the ansible configuration palybook to configure the elasticsearch on ec2 instance.


import boto3 
import os
import time


# aws keypair creation module
def key_creation(user):
    ec2 = boto3.client('ec2')
    user_key = user
    response = ec2.create_key_pair(KeyName=user_key)
    f = open(user_key+'.pem', 'w')
    f.write(response.get('KeyMaterial'))
    f.close()
    os.chmod(user_key + '.pem', 0o400)
    print("Keypair Created successfully")

# Spinning the ec2 instance with terraform code
def infra_creation():
    os.system("terraform init")
    os.system("terraform plan")
    os.system("terraform apply -auto-approve")

# Elasticsearch configuration using ansible playbooks.
def deploy_elasticsearch():
    os.system("cd ../configuration; cp ../infra_creation/mykeypair.pem .; ansible-playbook -i inventory elastic-playbook.yaml -vv")


#Calling the modues

key_creation('mykeypair')

time.sleep(10)

infra_creation()

deploy_elasticsearch()
