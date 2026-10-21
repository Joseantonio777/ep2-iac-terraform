#!/bin/bash
apt-get update -y
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
docker run -d --name web -p 80:80 --restart always nginxdemos/hello:latest
