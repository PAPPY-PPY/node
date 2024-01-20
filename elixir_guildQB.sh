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

printf '\033[32m%s\033[m\n' "その２：dockerの設定ファイルをダウンロードし、dockerを起動"
wget https://files.elixir.finance/Dockerfile
docker build . -f Dockerfile -t elixir-validator.
docker run -it --name ev elixir-validator
