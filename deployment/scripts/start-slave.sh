#!/bin/bash

source scripts/global-vars.sh

# Kill all children of this script when exiting
trap "$trap_exit_command" EXIT

tag=$1
master_ip=$2
public_ip=$3
private_ip=$4

# install dependency
# scp $ssh_options "scripts/cloud-deploy/user-script-slave.sh.template" "root@$public_ip:/root" || exit 6
# scp $ssh_options "scripts/cloud-deploy/global-vars.sh" "root@$public_ip:/root" || exit 7
# ssh $ssh_options root@$public_ip "chmod u+x /root/user-script-slave.sh.template;chmod u+x /root/global-vars.sh;/root/user-script-slave.sh.template"


init_command="
  export PATH=\$PATH:$remote_gopath/bin:$remote_work_dir/bin &&
  mkdir -p /root/go && mkdir -p /root/bin &&

  cd $remote_work_dir &&
  rsync --progress -rptz -e \"ssh $ssh_options\" root@$master_ip:$remote_tls_directory . &&
  cd tls-data &&
  ./generate.sh -f $public_ip $private_ip &&

  cd $remote_work_dir &&
  rsync --progress -rptz -e \"ssh \" root@$master_ip:$remote_gopath/bin/* $remote_gopath/bin/ &&
  mkdir -p config &&

  stubborn-scp.sh 5 $master_ip:$remote_code_dir/oldmir/oldmir-start.sh $remote_work_dir/bin &&
  chmod u+x $remote_work_dir/bin/oldmir-start.sh"

slave_command="
  ulimit -Sn $open_files_limit &&
  export PATH=\$PATH:$remote_gopath/bin:$remote_work_dir/bin &&
  discoveryslave $tag $master_ip:$master_port $public_ip $private_ip"

echo "Setting up slave: $public_ip ($private_ip)"

# Periodically check slave status and wait until it is running.
slave_status=$(scripts/remote-machine-status.sh $public_ip)
echo "Slave status ($public_ip): $slave_status"
while ! [[ "$slave_status" = "RUNNING" ]]; do
  # Sleep a bit and obtain new status.
  sleep $machine_status_poll_period
  slave_status=$(scripts/remote-machine-status.sh $public_ip)
  echo "Slave status: $slave_status"
done

# Wait until master server is ready.
# This needs to happen before initialization of the slave, as the master needs to prepare files (e.g. code binaries)
# That the slave downloads during initialization.
echo "Waiting for master server."
while ! ssh $ssh_options -q -o "ConnectTimeout=10" "root@$master_ip" "cat $remote_ready_file > /dev/null"; do
  sleep $machine_status_poll_period
  echo "Master not ready. Retrying in $machine_status_poll_period seconds."
done

# Initialize slave.
# Retrying introduced because sometimes, when many instances of this script are run in parallel,
# The ssh command fails with "connection reset by peer" or similar error.
while ! ssh $ssh_options root@$public_ip "$init_command"; do
  sleep 1
  echo "Retrying to initialize slave."
done

echo "Master ready. Starting slave process."
echo "ssh $ssh_options root@$public_ip "$slave_command""
ssh $ssh_options root@$public_ip "$slave_command"
