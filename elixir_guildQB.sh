!/bin/bash

echo ''
printf '\033[35m%s\033[m\n' ' ██████╗ ██╗   ██╗██╗██╗     ██████╗      ██████╗ ██████╗ '
printf '\033[35m%s\033[m\n' '██╔════╝ ██║   ██║██║██║     ██╔══██╗    ██╔═══██╗██╔══██╗'
printf '\033[35m%s\033[m\n' '██║  ███╗██║   ██║██║██║     ██║  ██║    ██║   ██║██████╔╝'
printf '\033[35m%s\033[m\n' '██║   ██║██║   ██║██║██║     ██║  ██║    ██║▄▄ ██║██╔══██╗'
printf '\033[35m%s\033[m\n' '╚██████╔╝╚██████╔╝██║███████╗██████╔╝    ╚██████╔╝██████╔╝'
printf '\033[35m%s\033[m\n' ' ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝      ╚══▀▀═╝ ╚═════╝'
echo ''

printf '\033[32m%s\033[m\n' "その１：Dockerのインストール"
printf '\033[32m%s\033[m\n' "続けていいすか？みたいに聞かれるのでenterを叩く。こんなやつ　→　Press [ENTER] to continue or Ctrl-c to cancel."

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce -y

printf '\033[32m%s\033[m\n' "その２：dockerの設定ファイルを作成"
touch Dockerfile
read -p "アドレスを入力: " ADDRESS
echo "ENV ADDRESS="$ADDRESS >>Dockerfile
read -p "秘密鍵を入力: " PKEY
echo "ENV PRIVATE_KEY="$PKEY >>Dockerfile
echo "ENV VALIDATOR_NAME==ELIXIRNODE" >>Dockerfile

printf '\033[32m%s\033[m\n' "その３：dockerを起動"
docker build . -f Dockerfile -t elixir-validator
docker run -it --name ev elixir-validator
