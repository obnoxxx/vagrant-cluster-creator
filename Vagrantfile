# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'
VAGRANTFILE_API_VERSION = "2"
VCC_VERSION = "1"


$default_ip_three_octets = "192.168.68."
$default_ip_4th_octet_start = 2

default_yml =  <<-EOF
---
version: 1
servers:
  - server1:
    libvirt:
      networks:
        - identifier: "private_network"
          auto_config: true
          ip: 192.168.69.2
          libvirt__network_name: "user_network"
          libvirt__netmask: 255.255.255.0
          libvirt__dhcp_enabled: true
          libvirt__dhcp_start: 192.168.69.128
          libvirt__dhcp_stop: 192.168.69.254
          libvirt__forward_mode: "nat"
      disks:
        - count: 2
          size: "1G"
  - server2:
    libvirt:
      networks:
        - identifier: "private_network"
          auto_config: true
          ip: 192.168.69.3
          libvirt__network_name: "user_network"
          libvirt__netmask: 255.255.255.0
          libvirt__dhcp_enabled: true
          libvirt__dhcp_start: 192.168.69.128
          libvirt__dhcp_stop: 192.168.69.254
          libvirt__forward_mode: "nat"
      disks:
        - count: 2
          size: "1G"
EOF



#Copied from vagrant-libvirt, to have same pattern of device creation
Alphabet = ('a'..'z').to_a
def vdev(num)
  s, q = '', num
  (q, r = (q - 1).divmod(26)) && s.prepend(Alphabet[r]) until q.zero?
  'vd'+s
end


if ARGV[0] == "up"
  config_file = ENV['VAGRANT_CLUSTER_CREATOR_CONFIG'] || default_yml
  #Load config file
  if File.file?(config_file)
    vcc_config = YAML.load_file(File.join(File.dirname(__FILE__), config_file))
    if !vcc_config.nil?
      if vcc_config['version'].to_s != VCC_VERSION
        print VCC_VERSION
        print "version #{vcc_config['version']} is not supported \n"
        exit
      end
    else
      print "Not a vagrant-cluster-creator file \n"
    end
  else
    print "\n\nNo config file found.\nUsing default config.\nCheckout examples directory for more options.\n\n"
    vcc_config = YAML::load(config_file)
  end
  File.open('./.last_used.conf', 'w') {|f| f.write vcc_config.to_yaml }

  if vcc_config['dump_output_config'] != false
    #open file to write gdeploy config
    $output_conf = open('output.conf', 'w')
    $output_conf.puts("# INFO: This file was generated by Vagrantfile")

    #hosts section
    $output_conf.puts "[hosts]"
    (0..vcc_config['servers'].length-1).each do |servernum|
      $output_conf.puts "#{$default_ip_three_octets}#{$default_ip_4th_octet_start + servernum}"
    end
    $output_conf.puts ""

    #backend section
    (0..vcc_config['servers'].length-1).each do |servernum|
      server = vcc_config['servers'][servernum]
      devices = Array.new
      diskid=2 #Assuming that there is only one main disk attached and skipping it
      if !server['libvirt'].nil? && !server['libvirt']['disks'].nil?
        ip = "#{$default_ip_three_octets}#{$default_ip_4th_octet_start + servernum}"
        $output_conf.puts "[backend-setup:#{ip}]"
        (0..server['libvirt']['disks'].length-1).each do |diskset|
          disk = server['libvirt']['disks'][diskset]
          if !disk['count'].nil?
            (0..disk['count']-1).each do |disknum|
              devices.push vdev(diskid)
              diskid = diskid + 1
            end
          end
        end
        $output_conf.puts "devices=#{devices.join(",")}"
        $output_conf.puts ""
      end
    end

    #close file
    $output_conf.close
  end #output_conf dump

else

  if File.file?('./.last_used.conf')
    vcc_config = YAML.load_file(File.join(File.dirname(__FILE__), './.last_used.conf'))
  else
    print "No saved config file with name .last_used.conf found.\n"
    print "Probably you executed a vagrant command without executing vagrant up first.\n"
    print "Exiting.\n"
    exit 1
  end

end


#=============================================================================
#Provider specific configure functions

#================================LIBVIRT=======================================
def configure_libvirt(config, vcc_config)
  config.vm.provider :libvirt do |lv|
    lv.driver = vcc_config['libvirt']['driver'] if vcc_config['libvirt']['driver']
    lv.host = vcc_config['libvirt']['host'] if vcc_config['libvirt']['host']
    lv.connect_via_ssh = vcc_config['libvirt']['connect_via_ssh'] if vcc_config['libvirt']['connect_via_ssh']
    lv.username = vcc_config['libvirt']['username'] if vcc_config['libvirt']['username']
    lv.password = vcc_config['libvirt']['password'] if vcc_config['libvirt']['password']
    lv.id_ssh_key_file = vcc_config['libvirt']['id_ssh_key_file'] if vcc_config['libvirt']['id_ssh_key_file']
    lv.socket = vcc_config['libvirt']['socket'] if vcc_config['libvirt']['socket']
    lv.uri = vcc_config['libvirt']['uri'] if vcc_config['libvirt']['uri']
    lv.storage_pool_name = vcc_config['libvirt']['storage_pool_name'] if vcc_config['libvirt']['storage_pool_name']
    lv.management_network_name = vcc_config['libvirt']['management_network_name'] if vcc_config['libvirt']['management_network_name']
    lv.management_network_address = vcc_config['libvirt']['management_network_address'] if vcc_config['libvirt']['management_network_address']
    lv.management_network_guest_ipv6 = vcc_config['libvirt']['management_network_guest_ipv6'] if vcc_config['libvirt']['management_network_guest_ipv6']
  end
end

def configure_libvirt_vm(config, server)
  config.vm.provider :libvirt do |lv, override|

    if !server['libvirt'].nil?
      override.vm.hostname = server['libvirt']['hostname'] if server['libvirt']['hostname']
      override.vm.box = server['libvirt']['box'] if server['libvirt']['box']
      if !server['libvirt']['box_url'].nil?
        #TODO: box_url could be an array
        override.vm.box_url = server['libvirt']['box_url']
      end
      lv.memory = (server['libvirt']['memory'] if server['libvirt']['memory']) || 1024
      lv.cpus = server['libvirt']['cpus'] if server['libvirt']['cpus']
      lv.nested = server['libvirt']['nested'] if server['libvirt']['nested']
    else  #let's assign defaults
      lv.memory = 1024
    end #override libvirt

  end
end

def configure_libvirt_network(config, server, serverid)
  config.vm.provider :libvirt do |lv, override|
    #one network which has static ip by default
    override.vm.network "private_network",
    auto_config: true,
    ip: "#{$default_ip_three_octets}#{$default_ip_4th_octet_start + serverid}",
    libvirt__network_name: "vagrant_cluster_creator_default",
    libvirt__netmask: "255.255.255.0",
    libvirt__dhcp_enabled: true,
    libvirt__dhcp_start: "#{$default_ip_three_octets}128",
    libvirt__dhcp_stop: "#{$default_ip_three_octets}254",
    libvirt__forward_mode: "none"



    if !server['libvirt'].nil? && !server['libvirt']['networks'].nil?
      server['libvirt']['networks'].each do |network|
        if network['identifier'] == "private_network" && !network['ip'].nil?
          override.vm.network network['identifier'].to_sym,
          auto_config: network['auto_config'],
          ip: network['ip'],
          libvirt__network_name: (network['libvirt__network_name'] if network['libvirt__network_name']),
          libvirt__netmask: (network['libvirt__netmask'] if network['libvirt__netmask']),
          libvirt__dhcp_enabled: (network['libvirt__dhcp_enabled'] if network['libvirt__dhcp_enabled']),
          libvirt__dhcp_start: (network['libvirt__dhcp_start'] if network['libvirt__dhcp_start']),
          libvirt__dhcp_stop: (network['libvirt__dhcp_stop'] if network['libvirt__dhcp_stop']),
          libvirt__forward_mode: (network['libvirt__forward_mode'] if network['libvirt__forward_mode'])
        elsif network['identifier'] == "private_network" &&
              network['type'] == "dhcp"
          override.vm.network network['identifier'].to_sym,
          auto_config: network['auto_config'],
          type: "dhcp"
        elsif network['identifier'] == "public_network"
          override.vm.network network['identifier'].to_sym,
            dev: network['dev']
        else
          print "network identifier not supported\n"
        end
      end
    end


  end
end



def configure_libvirt_disks(config, server, serverid)
  config.vm.provider :libvirt do |lv, override|

    #device names are just hints
    #refer:http://libvirt.org/formatdomain.html#elementsDisks
    #hence we use vdb as device name for every file
    if !server['libvirt'].nil? && !server['libvirt']['disks'].nil?
      (0..server['libvirt']['disks'].length-1).each do |diskset|
        disk = server['libvirt']['disks'][diskset]
        if !disk['count'].nil?
          (0..disk['count']-1).each do |disknum|
            lv.storage :file,
              size: disk['size'] || "1G"
          end
        end
      end
    end

  end
end
#=============================================================================


#===================================DOCKER====================================
#=============================================================================

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
#========================Configure Providers==================================
#We will configure provider level settings first, then move on to VM settings

#libvirt provider
  if !vcc_config['libvirt'].nil?
    configure_libvirt(config, vcc_config)
  end

#========================Configure VM/Containers/et===========================
  (0..vcc_config['servers'].length-1).each do |serverid|
    server = vcc_config['servers'][serverid]
    config.vm.define server.keys.first.to_s do |srv|

      #configure basic options
      srv.vm.hostname = server.keys.first.to_s
      srv.vm.box = "fedora/24-cloud-base"
      srv.ssh.username = server['ssh_username']
      srv.ssh.password = server['ssh_password']
      srv.ssh.private_key_path = server['ssh_private_key_path']
      srv.ssh.forward_agent = server['ssh_forward_agent']
      srv.ssh.insert_key = server['ssh_insert_key']
      #override basic options
      configure_libvirt_vm(srv, server)
      #configure_docker_container(config, server)

      #configure network options
      #empty
      #override network options
      configure_libvirt_network(srv, server, serverid)
      #configure_docker_network(config, server, m)

      #configure disks
      #empty
      #override disks
      configure_libvirt_disks(srv, server, serverid)
      #configure_docker_disks(config,server)

      #configure synced folders
      #always disable local folder sync
      srv.vm.synced_folder "./", "/vagrant", type: "rsync", disabled: "true"
      #configure as per user config
      #TODO: allow all options as provided by vagrant
      if !server['synced_folders'].nil?
        server['synced_folders'].each do |synced_folder|
          srv.vm.synced_folder synced_folder['source'], synced_folder['dest'], type: synced_folder['type'], disabled: synced_folder['disabled'] || false
        end
      end

      #TODO: handle server specific provisioners

    end #vm define loop
  end #for length loop
  #handle global provisioners
  #Add ssh public key found on host to the VMs for password less ssh to root
  config.vm.provision "shell" do |s|
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      mkdir -p /root/.ssh
      echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
      echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
    SHELL
  end
  #user defined provision steps
  #
end #vagrant configure
