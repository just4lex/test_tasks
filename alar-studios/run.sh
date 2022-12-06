#!/bin/bash
set -uex
# AWS_ACCESS_KEY_ID="super_secret_access_key_id_located_not_here"
# AWS_SECRET_ACCESS_KEY="super_secret_access_key_located_not_here"
ansible-playbook ec2_create.yml
ansible-playbook -i inventory.aws_ec2.yml ec2_setup.yml