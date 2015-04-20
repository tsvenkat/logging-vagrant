# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider "virtualbox" do |v|
     v.memory = 4096
  end
  #config.vm.network "private_network", type: "dhcp"

public_key_contents = File.open("ansible/log_key.pub").read.strip
nodes = (ENV["NUM_Of_NODES"] || "1").to_i
(1..nodes).each do |i|
  config.vm.define "lg-#{i}" do |l|
    l.vm.box = "ubuntu/trusty64"
    es_path =  'elasticdata_'+i.to_s
    FileUtils::mkdir_p es_path	
    l.vm.synced_folder "./logstash-conf", "/etc/logstash/conf.d"
    l.vm.synced_folder "./elasticsearch", "/etc/elasticsearch"
    l.vm.synced_folder "./"+es_path, "/data", owner: "vagrant", group: "vagrant"
    vm_ip = "172.28.128."+(20+i).to_s
    l.vm.network :private_network, ip: vm_ip
    l.vm.network :forwarded_port, host: 5000+i, guest: 5000 
    l.vm.network :forwarded_port, host: 9200+i, guest: 9200 
    l.vm.network :forwarded_port, host: 54328+i, guest: 54328 
    #l.vm.network :forwarded_port, guest: 22, host: 2225
    l.vm.provision :shell, inline: "echo #{public_key_contents} >> /home/vagrant/.ssh/authorized_keys" 
  end
end

# update the inventory file based on VM details
File.open("ansible/hosts/vms","w") do |fp|
   (1..nodes).each do |i|
      fp.puts "lg-#{i} ansible_ssh_host=172.28.128.#{20+i}"
   end
   fp.puts "\n[loggers]"
   (1..nodes).each do |i|
      fp.puts "lg-#{i}"
   end
end

  config.vm.define "deployer" do |deployer|
     deployer.vm.box = "ubuntu/trusty64"
     deployer.vm.synced_folder "./ansible", "/ansible"
     deployer.vm.provision :shell, path: "install_ansible.sh" 
=begin
     deployer.vm.provision :ansible do |ansible|
         ansible.groups = {
              "loggers" => ["lg-1","lg-2"],
	      "all_groups:children" => ["loggers"]
         }
         ansible.playbook = "ansible/logging.yml"
     end
=end
     #deployer.vm.network :forwarded_port, guest: 22, host: 2226
  end

  #config.vm.provision :shell, path: "bootstrap.sh"
  #config.vm.network :forwarded_port, host: 4567, guest: 80
  #config.vm.synced_folder ".", "/vagrant", disabled: true

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "default.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { mysql_password: "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
