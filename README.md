# reference
1. [nodebrand](https://nodebrand.xyz/entry/0G-Labs-Validator-Node-Guide0508-Update)
2. [trusted-point](https://github.com/trusted-point/0g-tools)



# start here
get the script
```
curl -o 0gchain-setup.sh https://raw.githubusercontent.com/jackleeinitianode/0g-validator-node/main/0gchain-setup.sh &&  \
chmod +x 0gchain-setup.sh &&  \
./0gchain-setup.sh
```

complete step 1, 2, 3. then create the services file.
```
sudo tee /etc/systemd/system/ogd.service > /dev/null <<EOF
[Unit]
Description=OG Node
After=network.target

[Service]
User=root
Type=simple
ExecStart=$(which 0gchaind) start --json-rpc.api eth,txpool,personal,net,debug,web3 --home $HOME/.0gchain
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.0gchain"
Environment="DAEMON_NAME=0gchaind"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.0gchain/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```

start and enjoy!
```
sudo systemctl daemon-reload && \
sudo systemctl enable ogd && \
sudo systemctl restart ogd
```

# useful cheat sheet
import wallet
```
0gchaind keys unsafe-import-eth-key $WALLET_NAME <privatekey>
```
get wallet evm address
```
0gchaind debug addr $(0gchaind keys show $WALLET_NAME -a) | grep 'Address (hex):' | awk -F ': ' '{print "0x" $2}'
```
check wallet balance
```
0gchaind q bank balances $(0gchaind keys show $WALLET_NAME -a)
```
check block height
```
0gchaind status | jq '{ latest_block_height: .sync_info.latest_block_height, catching_up: .sync_info.catching_up }'
```


# buy me a coffee?
```
evm:  0x9b738d96a2654eef7a32ef14d1569bf90e792b39
sol:  64Jt9FfP24g4jKkWmFGjBWDaGB79j7VW57jRPpoLwZhR
```
