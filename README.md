# vagrant-cluster-creator
A JSON config file based approach to creating cluster of machines using vagrant

# How to
1. `git clone https://github.com/raghavendra-talur/vagrant-cluster-creator.git`
2. `cd vagrant-cluster-creator`
3. `vagrant up # You will get the default config`

If you want a cluster of machines you get to define them in a JSON config file and then call
`VAGRANT_CLUSTER_CREATOR_CONFIG='./config.yml' vagrant up`

Look into the examples directory for sample config files.

#NOTE
1. Supports only libvirt provider as of now.

Contributions welcome!




