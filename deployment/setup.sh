#!/bin/bash

export user=$(id -un)
export group=$(id -gn)

sudo apt-get update
sudo apt-get install -y curl git
sudo apt-get install -y python2
sudo apt-get install -y python-numpy
sudo apt-get install -y build-essential
sudo apt-get install -y protobuf-compiler
sudo apt-get install -y protobuf-compiler-grpc

cd ~

wget https://storage.googleapis.com/golang/go1.20.1.linux-amd64.tar.gz
tar xpzf go1.20.1.linux-amd64.tar.gz

sudo mkdir -p /opt/gopath
sudo chown -R  $user:$group /opt/gopath

export PATH=$PATH:~/go/bin/:/opt/gopath/bin/
export GOPATH=/opt/gopath
export GOROOT=~/go
export GIT_SSL_NO_VERIFY=1
export GO111MODULE=off
mkdir -p $GOPATH/bin
export GOBIN=$GOPATH/bin

cat << EOF >> ~/.bashrc
export PATH=$PATH:~/go/bin/:/opt/gopath/bin/
export GOPATH=/opt/gopath
export GOROOT=~/go
export GIT_SSL_NO_VERIFY=1
export GO111MODULE=off
export GOBIN=$GOPATH/bin
EOF

go get -u google.golang.org/grpc
go get -u github.com/golang/protobuf/protoc-gen-go
go get -u github.com/op/go-logging
go get -u golang.org/x/net/context
go get -u  gopkg.in/yaml.v2
go get -u github.com/rs/zerolog/log

mkdir -p /opt/gopath/src/github.com/hyperledger-labs/
cd /opt/gopath/src/github.com/hyperledger-labs/
if [ -d "/opt/gopath/src/github.com/hyperledger-labs/mirbft" ]; then
  rm -rf mirbft
fi
git clone --single-branch --branch research https://github.com/JeffXiesk/mirbft.git
cd /opt/gopath/src/github.com/hyperledger-labs/mirbft
# git checkout research
git pull origin research
./run-protoc.sh
cd /opt/gopath/src/github.com/hyperledger-labs/mirbft/server
go build
cd /opt/gopath/src/github.com/hyperledger-labs/mirbft/client
go build