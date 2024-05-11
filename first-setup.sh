#!/bin/bash
set -e
set -o pipefail 

####################################################
#### Update apt
####################################################

sudo apt update
sudo apt install unzip

####################################################
#### Set up AWS CLI
####################################################
echo "--------------------------------------------------------------------------" 
echo "--------------------------- SETTING UP AWS CLI ---------------------------" 
echo "--------------------------------------------------------------------------" 

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

####################################################
#### Setup Node
####################################################
echo "-----------------------------------------------------------------------" 
echo "--------------------------- SETTING UP NODE ---------------------------" 
echo "-----------------------------------------------------------------------" 

sudo apt update
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 
sudo apt-get install -y nodejs
node -v
npm -v

npm install -g pnpm


####################################################
#### Configure GIT
####################################################
echo "---------------------------------------------------------------------" 
echo "--------------------------- CONFIGURE GIT ---------------------------" 
echo "---------------------------------------------------------------------" 

git config --global user.name "sachin.punyani"
git config --global user.email "sachin.punyani@gmail.com"
git config --global credential.helper store

####################################################
#### Set up Miniconda
####################################################
echo "----------------------------------------------------------------------------" 
echo "--------------------------- SETTING UP MINICONDA ---------------------------" 
echo "----------------------------------------------------------------------------" 

mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh


## initialize newly-installed Miniconda
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

source ~/.bashrc

echo "Conda path : $(which conda)" 


####################################################
#### Create CONDA environments
####################################################

echo "---------------------------------------------------------------------------------" 
echo "--------------------------- CREATE CONDA ENVIRONMENTS ---------------------------" 
echo "---------------------------------------------------------------------------------" 

conda create -n campus python --yes
conda create -n capmkt python --yes
