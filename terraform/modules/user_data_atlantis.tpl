#!/bin/bash
sudo yum update -y
sudo yum install wget
sudo yum search docker -y
sudo yum install docker -y
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl status docker.service