#! /usr/bin/env bash

file=go1.12.4.linux-amd64.tar.gz
if [ ! -f "$file" ]; then
    wget https://studygolang.com/dl/golang/$file
else
    echo "file already exists"
fi

sudo tar -C /usr/local -xzf $file
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

mkdir $HOME/go

echo "now re-login to enable go command"
