#!/bin/bash
export user=$(id -un)
export group=$(id -gn)

export PATH=$PATH:~/go/bin/:/opt/gopath/bin/
export GOPATH=/opt/gopath
export GOROOT=~/go
export GO111MODULE=off

sudo mkdir -p /opt/gopath/src/github.com/hyperledger-labs/
sudo chown -R $user:$group  /opt/gopath/
cd /opt/gopath/src/github.com/hyperledger-labs/
if [ ! -d "/opt/gopath/src/github.com/hyperledger-labs/mirbft" ]; then
  git clone https://github.com/JeffXiesk/mirbft.git
fi
cd /opt/gopath/src/github.com/hyperledger-labs/mirbft
git checkout research
git pull
./run-protoc.sh
cd /opt/gopath/src/github.com/hyperledger-labs/mirbft/server
go build
cd /opt/gopath/src/github.com/hyperledger-labs/mirbft/client
go build