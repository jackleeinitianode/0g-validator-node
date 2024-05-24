#!/bin/bash
# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "root is required."
    echo "Please use sudo -i switch to root account and rerun the script"
    exit 1
fi


function remove_0gvalidatornode(){
	sudo rm /etc/systemd/system/ogd.service
	sudo systemctl stop ogd
	sudo systemctl disable ogd
	sudo systemctl daemon-reload
	rm -r -f 0g-chain/
	rm -r -f $HOME/.0gchain/
	rm -r -f /etc/systemd/system/ogd.service
}


function setup_environment(){
	read -p "SET MONIKER [jackmoniker]: " MONIKER
	MONIKER=${MONIKER:-jackmoniker}
	
	read -p "SET WALLET_NAME [jackwallet]: " WALLET_NAME
	WALLET_NAME=${WALLET_NAME:-jackwallet}

	read -p "SET RPC_PORT [26657]: " RPC_PORT
	RPC_PORT=${RPC_PORT:-26657}
	
	
	echo 'export MONIKER=$MONIKER' >> ~/.bash_profile
	echo 'export CHAIN_ID="zgtendermint_16600-1"' >> ~/.bash_profile
	echo 'export WALLET_NAME='$WALLET_NAME' >> ~/.bash_profile
	echo 'export RPC_POR'$RPC_PORT' >> ~/.bash_profile
	source $HOME/.bash_profile
}


# Function to install environment
function install_package() {
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

# Function to install-0g-validator-node
function install_0gvalidatornode() {
    setup_environment
	install_environment_package
	clone_script_0gvalidator
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
        echo "1. setup_environment"
	echo "2. install_package"
        echo "9. Exit"
	echo "99. Remove 0g validator node"
        echo "##############################################################################"
        read -p "Select function: " choice
        case $choice in
        1)
        	setup_environment
        	;;
        2)
		install_package
		;;
	9)
		break
		;;
	99)
		remove_0gvalidatornode
		;;
        *)
        	echo "Choice function again"
        	;;
        esac
    done
}

# Call the menu function
menu
