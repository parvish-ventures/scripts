#!/bin/bash
set -e
set -o pipefail 

# Configuration section
PRE_SETUP=true
AWS=true
NODE=true
MINICONDA=true
GIT=true
CONDA_ENV=true
VSCODE=true
EXTENSIONS=true

if [ "$PRE_SETUP" = true ] ; then
    ####################################################
    #### Update apt and setup other pre-requisites
    ####################################################

    sudo apt update
    sudo apt install unzip
fi

if [ "$AWS" = true ] ; then
    ####################################################
    #### Set up AWS CLI
    ####################################################
    echo "--------------------------------------------------------------------------" 
    echo "--------------------------- SETTING UP AWS CLI ---------------------------" 
    echo "--------------------------------------------------------------------------" 

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

if [ "$NODE" = true ] ; then
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

    sudo npm install -g npm@latest
    node -v
    npm -v

    sudo npm install -g pnpm
fi

if [ "$GIT" = true ] ; then
    ####################################################
    #### Configure GIT
    ####################################################
    echo "---------------------------------------------------------------------" 
    echo "--------------------------- CONFIGURE GIT ---------------------------" 
    echo "---------------------------------------------------------------------" 

    git config --global user.name "sachin.punyani"
    git config --global user.email "sachin.punyani@gmail.com"
    git config --global credential.helper store
fi

if [ "$MINICONDA" = true ] ; then
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

    ## Activate Miniconda in the current shell
    CONDA_BASE=$(~/miniconda3/bin/conda info --base)
    source "$CONDA_BASE/etc/profile.d/conda.sh"

    echo "Conda path : $(which conda)" 
fi

if [ "$CONDA_ENV" = true ] ; then
    ####################################################
    #### Create CONDA environments
    ####################################################

    echo "---------------------------------------------------------------------------------" 
    echo "--------------------------- CREATE CONDA ENVIRONMENTS ---------------------------" 
    echo "---------------------------------------------------------------------------------" 

    conda create -n campus python --yes
    conda create -n capmkt python --yes
fi

if [ "$VSCODE" = true ] ; then
    ####################################################
    #### Setup vscode extensions
    ####################################################

    echo "-------------------------------------------------------------------------------" 
    echo "--------------------------- SETUP VSCODE EXTENSIONS ---------------------------" 
    echo "-------------------------------------------------------------------------------" 

    # 1. Download (using wget)
    wget https://update.code.visualstudio.com/latest/server-linux-x64/stable

    # 2. Extract
    tar -xzvf stable

    # 3. Move to a suitable location (optional)
    sudo mv vscode-server-linux-x64 /usr/local/lib/vscode-server

    # 4. Create a systemd service file (optional)
    # Variables
    service_file="/etc/systemd/system/code-server.service"
    vscode_server_path="/usr/local/lib/vscode-server/bin/"  # Adjust if installed elsewhere
    username=$(whoami)  # Get current user's username

    # Create service file content
    service_content="[Unit]
    Description=VS Code Server
    After=network.target

    [Service]
    Type=simple
    User=$username
    ExecStart=$vscode_server_path/code-server --host 0.0.0.0
    Restart=always

    [Install]
    WantedBy=multi-user.target"

    # Write service file content
    echo "$service_content" | sudo tee "$service_file" > /dev/null

    # Reload systemd daemon
    sudo systemctl daemon-reload

    echo "VS Code Server service file created at $service_file"

    # 5. Enable and start the service automatically
    sudo systemctl enable code-server
    sudo systemctl start code-server
    echo "VS Code Server service enabled and started."
fi

if [ "$EXTENSIONS" = true ] ; then
    #6. Install extensions
    extensions_file="vscode_extensions.txt" 

    # Check if VS Code Server is running
    if ! pgrep -x "code-server" > /dev/null; then
            echo "VS Code Server is not running. Please start it before running this script."
            exit 1
    fi

    while IFS= read -r extension; do
            echo "Installing extension: $extension"
            code-server --install-extension "$extension"
    done < "$extensions_file"
fi