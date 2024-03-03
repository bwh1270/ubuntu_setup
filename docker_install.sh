#! /bin/bash

# Install Docker Engine from Docker's apt repository.
echo "Let's start installing the Docker Engine!"

echo "Uninstall the old versions of Docker first."
sudo apt-get remove docker docker-engine docker-io containerd runc

# Configure the Repository
echo "Now start installing stages."

echo "Set up the repository"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "Add Docker's official GPG key"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Use the following command to set up the repository."
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Install Docker Engine, containerd, and Docker Compose."
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Verification with hello-world image."
sudo docker run hello-world