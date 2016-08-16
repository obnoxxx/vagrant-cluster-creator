# vagrant-cluster-creator
A YAML config file based approach to creating cluster of machines using vagrant

# How to use
1. `git clone https://github.com/raghavendra-talur/vagrant-cluster-creator.git`
2. `cd vagrant-cluster-creator`
3. `vagrant up # You will get the default config`

If you want a cluster of machines you get to define them in a YAML config file and then call
`VAGRANT_CLUSTER_CREATOR_CONFIG='./config.yml' vagrant up`

Look into the examples directory for sample config files.

#NOTE
1. Supports only libvirt provider as of now.
2. No provisioning/provision steps support in the config file.

# Requirements
A working Vagrant setup

## Why?
Sometimes you might need to quickly create a cluster of machines and there is no other tool better than vagrant; but what if you want to change the configuration of cluster frequently? Yes, exactly, move the data(config) out of the Vagrantfile and hack away to glory.

## What?
This tool uses vagrant to create a cluster of nodes based on a simple YAML file that user writes. If no config file is provided default configuration is used. Sample files have been provided in the examples directory.

  1. Host machines' public keys are added to VM's authorized keys.
  2. It also dumps a conf file that can be provided as input to other tools.

## How?
A generic vagrantfile loops over the config YAML provided to determine the number of servers, network interfaces and disks per server.  The implementation covers only libvirt provider, however, config file has been designed to accomodate docker and other providers in future.


Contributions welcome!




