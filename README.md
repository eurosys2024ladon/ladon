# Ladon - High-Performance Multi-BFT Consensus via Dynamic Global Ordering
## ABSTRACT
Multi-BFT consensus runs multiple leader-based consensus instances in parallel, circumventing the leader bottleneck of a single instance. 
However, it contains an Achilles’ heel: the need to globally order output blocks across instances. Deriving this global ordering is challenging because it must cope with different rates at which blocks are produced by instances. Prior Multi-BFT designs assign each block a global index before creation, leading to poor performance. We propose Ladon, a high-performance Multi-BFT protocol that allows varying instance block rates. Our key idea is to order blocks across instances dynamically, which eliminates blocking on slow instances. We achieve dynamic global ordering by assigning monotonic ranks to blocks. We pipeline rank coordination with the consensus process to reduce protocol overhead and combine aggregate signatures with rank information to reduce message complexity. Besides, the dynamic ordering enables blocks to be globally ordered according to their generation, which respects inter-block causality.

Ladon is a distributed consensus framework built on top of the ISS framework from Hyperledger-labs. For a detailed modular explanation and a glossary of terms, please refer to [here](../../tree/research-iss/README.md). Ladon extends the capabilities of ISS by incorporating the following modifications:

Pipeline the Rank Collection in the Consensus Protocol: Ladon introduces a pipelined step in the consensus protocol for collecting the ranks of participating nodes, which is then utilized for the global ordering of blocks.

Dynamic Global Ordering Algorithm: Ladon replaces the existing global ordering algorithm in ISS with a dynamic ordering algorithm. This new algorithm enhances system performance and efficiency, particularly in the presence of stragglers.

### Supported Consensus Protocols: 
- PBFT (Practical Byzantine Fault Tolerance) 
- HotStuff

## Installation
### Cloning the repository
Create a GOPATH directory and make sure you are the owner of it:

`sudo mkdir -p /opt/gopath/`

`sudo chown -R $user:$group  /opt/gopath/`

where `$user` and `$group` your user and group respectively.

Create a directory to clone the repository into:

`mkdir -p /opt/gopath/src/github.com/hyperledger-labs/`

Clone this repository unter the directory you created:

`cd /opt/gopath/src/github.com/hyperledger-labs/`

`git clone https://github.com/hyperledger-labs/ladon.git`

Checkout the`research-ladon` branch.

### Installing Dependencies
With `/opt/gopath/src/github.com/hyperledger-labs/ladon` as working directory, go to the deployment directory:

`cd deployment`

Configure the `user` and `group` in `vars.sh`

To install Golang and requirements: 

`source scripts/install-local.sh`

**NOTE**: The `install-local.sh` script, among other dependencies, installs `Go` in the home directory, sets GOPATH to `/opt/gopath/bin/` and edits `~/.bashrc`.

The default path to the repository is set to: `/opt/gopath/src/github.com/hyperledger-labs/ladon/`.


### Ladon Installation
The `run-protoc.sh` script needs to be run from the project root directory (i.e. `ladon`) before compiling the Go
files. 

**IMPORTANT**: go modules are not supported. Disable with the command: `export GO111MODULE=off` before installation.

Compile and install the go code by running `go install ./...` from the project root directory.


## Deployment & Permformance Metrics
Detailed instructions can be found [here](deployment/).
