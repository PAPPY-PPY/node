!/bin/bash

echo ''
printf '\033[35m%s\033[m\n' ' ██████╗ ██╗   ██╗██╗██╗     ██████╗      ██████╗ ██████╗ '
printf '\033[35m%s\033[m\n' '██╔════╝ ██║   ██║██║██║     ██╔══██╗    ██╔═══██╗██╔══██╗'
printf '\033[35m%s\033[m\n' '██║  ███╗██║   ██║██║██║     ██║  ██║    ██║   ██║██████╔╝'
printf '\033[35m%s\033[m\n' '██║   ██║██║   ██║██║██║     ██║  ██║    ██║▄▄ ██║██╔══██╗'
printf '\033[35m%s\033[m\n' '╚██████╔╝╚██████╔╝██║███████╗██████╔╝    ╚██████╔╝██████╔╝'
printf '\033[35m%s\033[m\n' ' ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝      ╚══▀▀═╝ ╚═════╝'
echo ''

#step1
printf '\033[32m%s\033[m\n' "その１：まずgethをダウンロードしてインストールする"

wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.23-d901d853.tar.gz
tar -xvzf geth-linux-amd64-1.10.23-d901d853.tar.gz

#step2
printf '\033[32m%s\033[m\n' "その２：アカウント作成"

printf '\033[32m%s\033[m\n' "８文字以上のパスワードを設定する。２回聞かれる。"
printf '\033[31m%s\033[m\n' "忘れないようにメモること"

cd geth-linux-amd64-1.10.23-d901d853/
mkdir /root/geth-linux-amd64-1.10.23-d901d853/keystore/
if [ "$(ls /root/geth-linux-amd64-1.10.23-d901d853/keystore/ | wc -l)" ] >1; then
    rm -rf /root/geth-linux-amd64-1.10.23-d901d853/keystore/
    mkdir /root/geth-linux-amd64-1.10.23-d901d853/keystore/
fi
./geth account new --keystore ./keystore
UTC="$(ls /root/geth-linux-amd64-1.10.23-d901d853/keystore/)"
export UTC
PKEY="0x""$(awk -F \" '{print $4}' /root/geth-linux-amd64-1.10.23-d901d853/keystore/$UTC)"
export PKEY
echo $PKEY
printf '\033[31m%s\033[m\n' "↑このアドレスへBNBtestnetのガスを送る。0,01とかで良い。送ったらenterを叩き次へ進む"
read _

#step3
printf '\033[32m%s\033[m\n' "その３：Dockerのインストール"
printf '\033[32m%s\033[m\n' "続けていいすか？みたいに聞かれるのでenterを叩く。こんなやつ　→　Press [ENTER] to continue or Ctrl-c to cancel."

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce -y

#step4
printf '\033[32m%s\033[m\n' "その４：ノードをインストールする"

docker pull nulink/nulink:latest
cd /root
mkdir nulink
cp /root/geth-linux-amd64-1.10.23-d901d853/keystore/* /root/nulink
chmod -R 777 /root/nulink

#step5
printf '\033[32m%s\033[m\n' "その５：ノードの初期設定を行う"

KEY="/root/geth-linux-amd64-1.10.23-d901d853/keystore/$UTC"
export KEY

sleep 2

read -p "先程設定したパスワードを入力: " NULINK_KEYSTORE_PASSWORD
export NULINK_KEYSTORE_PASSWORD
read -p "新しくパスワードを設定。同じでも良い: " NULINK_OPERATOR_ETH_PASSWORD
export NULINK_OPERATOR_ETH_PASSWORD

echo "アドレス： $PKEY"
echo "キーストアのパスワード：$NULINK_KEYSTORE_PASSWORD"
echo "オペレーターのパスワード: $NULINK_OPERATOR_ETH_PASSWORD"

#step6
printf '\033[32m%s\033[m\n' "その６：ノードを起動"

docker ps -q --filter "name=ursula" | grep -q . && docker kill ursula && docker rm ursula
printf '\033[32m%s\033[m\n' "IPが正しいか聞かれるのでyを入力しenter"
printf '\033[32m%s\033[m\n' "その後シードフレーズが表示されるのでメモる。メモったらyで進み、シードフレーズをコピペしてエンターを入力する"
docker run -it --rm \
    -p 9151:9151 \
    -v /root/nulink:/code \
    -v /root/nulink:/home/circleci/.local/share/nulink \
    -e NULINK_KEYSTORE_PASSWORD \
    nulink/nulink nulink ursula init \
    --signer keystore:///code/$UTC \
    --eth-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
    --network horus \
    --payment-provider https://data-seed-prebsc-2-s2.binance.org:8545 \
    --payment-network bsc_testnet \
    --operator-address $PKEY \
    --max-gas-price 10000000000

sleep 5

docker run --restart on-failure -d \
    --name ursula \
    -p 9151:9151 \
    -v /root/nulink:/code \
    -v /root/nulink:/home/circleci/.local/share/nulink \
    -e NULINK_KEYSTORE_PASSWORD \
    -e NULINK_OPERATOR_ETH_PASSWORD \
    nulink/nulink nulink ursula run --no-block-until-ready

printf '\033[35m%s\033[m\n' '起動完了。モニター開始 '
echo $PKEY
echo "↑dashbordでoperatorに入力するアドレスはこれ"
docker logs -f ursula
