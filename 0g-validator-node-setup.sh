#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "root is required."
    echo "Please use sudo -i switch to root account and rerun the script"
    exit 1
fi


function setup_environment(){
	read -p "SET MONIKER NAME: " input_MONIKER
	read -p "SET WALLET_NAME: " input_WALLET_NAME
	read -p "SET WALLET_NAME: " input_RPC_PORT
	echo 'export MONIKER="'$input_MONIKER'"' >> ~/.bash_profile
	echo 'export CHAIN_ID="zgtendermint_16600-1"' >> ~/.bash_profile
	echo 'export WALLET_NAME="'input_WALLET_NAME'"' >> ~/.bash_profile
	echo 'export RPC_PORT="'$input_RPC_PORT'"' >> ~/.bash_profile
	source $HOME/.bash_profile
}

# Function to install environment
function install_environment_package() {
	sudo apt update
	sudo apt install curl git jq build-essential gcc unzip wget lz4 -y
	cd $HOME && \
	ver="1.21.3" && \
	wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
	sudo rm -rf /usr/local/go && \
	sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
	rm "go$ver.linux-amd64.tar.gz" && \
	echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
	source $HOME/.bash_profile && \
	go version
}

function clone_script_0gvalidator(){
	git clone -b v0.1.0 https://github.com/0glabs/0g-chain.git
	cd 0g-chain
	make install
	0gchaind version
}


# Function to install-0g-validator-node
function install_0gvalidatornode() {
    setup_environment
	install_environment_package
	clone_script_0gchain
}

# Main menu function
function menu() {
    while true; do
		echo "##############################################################################"
		echo "##############################################################################"
                echo "########  Twitter: @jleeinitianode                                    ########"
		echo "########  Buy me a coffee ?                                           ########"
		echo "########  evm:   0x9b738d96a2654eef7a32ef14d1569bf90e792b39           ########"
		echo "########  sol:   64Jt9FfP24g4jKkWmFGjBWDaGB79j7VW57jRPpoLwZhR         ########"
		echo "##############################################################################"
		echo "##############################################################################"
		echo ""
        echo "1. Install 0g validator node"
        echo "2. Exit"
        echo "##############################################################################"
        read -p "Select function: " choice
        case $choice in
        1)
            install_0gvalidatornode
            ;;
        2)
            break
            ;;
        *)
            echo "Choice function again"
            ;;
        esac
    done
}

# Call the menu function
menu

