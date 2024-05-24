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
	read -p "SET MONIKE [jackmonike]: " inMONIKE
	inMONIKE=${inMONIKE:-jackmonike}
	read -p "SET WALLET_NAME [jackwallet]: " inWALLET_NAME
	inWALLET_NAME=${inWALLET_NAME:-jackwallet}
	read -p "SET RPC_PORT [26657]: " inRPC_PORT
	inRPC_PORT=${inRPC_PORT:-26657}
	
	echo 'export MONIKER=$inMONIKE' >> ~/.bash_profile
	echo 'export CHAIN_ID="zgtendermint_16600-1"' >> ~/.bash_profile
	echo 'export WALLET_NAME=$inWALLET_NAME' >> ~/.bash_profile
	echo 'export RPC_PORT=$inRPC_PORT' >> ~/.bash_profile
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

function git_clone_install(){
	cd
	git clone -b v0.1.0 https://github.com/0glabs/0g-chain.git
	cd 0g-chain
	make install
	
	cd $HOME
	0gchaind config chain-id $CHAIN_ID
	0gchaind config node tcp://localhost:$RPC_PORT
	0gchaind config keyring-backend os
	0gchaind init $MONIKER --chain-id $CHAIN_ID
	
	# download genesis
	wget -P ~/.0gchain/config https://github.com/0glabs/0g-chain/releases/download/v0.1.0/genesis.json
	# Update addrbook
	curl -o $HOME/.0gchain/config/addrbook.json https://zerog.snapshot.nodebrand.xyz/addrbook.json
	SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656,f878d40c538c8c23653a5b70f615f8dccec6fb9f@54.215.187.94:26656,41143f378016a05e1fa4fa8aa028035a82761b48@154.12.235.67:46656" 
	sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.0gchain/config/config.toml
	EXTERNAL_IP=$(wget -qO- eth0.me) \
	PROXY_APP_PORT=26658 \
	P2P_PORT=26656 \
	PPROF_PORT=6060 \
	API_PORT=1317 \
	GRPC_PORT=9090 \
	GRPC_WEB_PORT=9091
	
	sed -i -e "s/\(proxy_app = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$PROXY_APP_PORT\"/" $HOME/.0gchain/config/config.toml
	sed -i -e "s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$RPC_PORT\"/" $HOME/.0gchain/config/config.toml
	sed -i -e "s/\(pprof_laddr = \"\)\([^:]*\):\([0-9]*\).*/\1localhost:$PPROF_PORT\"/" $HOME/.0gchain/config/config.toml
	sed -i -e "/\[p2p\]/,/^\[/{s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$P2P_PORT\"/}" $HOME/.0gchain/config/config.toml
	sed -i -e "/\[p2p\]/,/^\[/{s/\(external_address = \"\)\([^:]*\):\([0-9]*\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/; t; s/\(external_address = \"\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/}" $HOME/.0gchain/config/config.toml
	sed -i -e "/\[api\]/,/^\[/{s/\(address = \"tcp:\/\/\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$API_PORT\4/}" $HOME/.0gchain/config/app.toml
	sed -i -e "/\[grpc\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_PORT\4/}" $HOME/.0gchain/config/app.toml
	sed -i -e "/\[grpc-web\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_WEB_PORT\4/}" $HOME/.0gchain/config/app.toml
	sed -i.bak -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.0gchain/config/app.toml
	sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.0gchain/config/app.toml
	sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.0gchain/config/app.toml
	sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ua0gi\"/" $HOME/.0gchain/config/app.toml
	sed -i "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.0gchain/config/config.toml
	sed -i -e 's/address = "127.0.0.1:8545"/address = "0.0.0.0:8545"/' $HOME/.0gchain/config/app.toml
	sed -i -e 's/ws-address = "127.0.0.1:8546"/ws-address = "0.0.0.0:8546"/' $HOME/.0gchain/config/app.toml
	

	# Update Peers
	curl -o $HOME/update_0g_peers.sh https://zerog.snapshot.nodebrand.xyz/update_0g_peers.sh
	chmod +x $HOME/update_0g_peers.sh
	$HOME/update_0g_peers.sh
	# update addrbook
	curl -o $HOME/.0gchain/config/addrbook.json https://zerog.snapshot.nodebrand.xyz/addrbook.json


	# download snapshot
	cp $HOME/.0gchain/data/priv_validator_state.json $HOME/.0gchain/priv_validator_state.json.backup
	0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain --keep-addr-book
	cd
	wget https://snapshots-testnet.nodejumper.io/0g-testnet/0g-testnet_latest.tar.lz4
	mkdir snapshotbackup
	chmod 777 snapshotbackup
	cp 0g-testnet_latest.tar.lz4 snapshotbackup/

	lz4 -c -d $HOME/snapshotbackup/0g-testnet_latest.tar.lz4 | tar -x -C $HOME/.0gchain
	mv $HOME/.0gchain/priv_validator_state.json.backup $HOME/.0gchain/data/priv_validator_state.json
	# sudo systemctl restart ogd && sudo journalctl -u ogd -f -o cat

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
	echo "3. git clone install"
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
		3)
		git_clone_install
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
