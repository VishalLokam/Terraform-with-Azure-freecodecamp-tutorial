#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
software-properties-common &&
curl -fsSL https://get.docker.com -o install-docker.sh &&
sudo sh install-docker.sh &&
sudo usermod -aG docker $(whoami)


