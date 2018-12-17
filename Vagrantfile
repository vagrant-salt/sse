require 'json'

proxy = ''
domain = 'test.local'
saltEnterpriseInstaller = 'SaltStack_Enterprise_5.5_Installer.tar.gz'
nodes_file = File.read('nodes.json')
nodes = JSON.parse(nodes_file)

# Important!
# 1. when editing the file 'nodes.json', make sure the ssemaster machine is the last one in the list
#    this is required so that it will be the last one to be processed, when adding the minion keys on the saltmaster and running the salt states
# 2. The saltEnterpriseInstaller file must already exist in the local vagrant folder, before you can run 'vagrant up'
#    You can retrieve it from the official SaltStack enterprise website, from the 'support' section
# 3. If you are not using proxy, set the 'proxy' parameter up-top to an empty string

ssemasterFQDN = "#{nodes['ssemaster']['hostname']}.#{domain}"
ssemasterIP = nodes['ssemaster']['ip']

Vagrant.configure("2") do |config|
   nodes.each do |role, properties|
      config.vm.define properties["hostname"] do |nodeconfig|
         nodeconfig.vm.provider :virtualbox do |box|
            box.name = properties["hostname"]
            box.customize [
               "modifyvm", :id,
               "--cpuexecutioncap", "50",
               "--memory", properties["ram"],
               "--cpus", "2",
            ]
         end
         nodeFQDN = "#{properties['hostname']}.#{domain}"
         #nodeconfig.vm.synced_folder ".", "/vagrant", disabled: true
         nodeconfig.vm.box = properties["box"]
         nodeconfig.vm.hostname = nodeFQDN
         nodeconfig.vm.network :private_network, ip: properties["ip"], virtualbox__intnet: true
         # enable port forwarding on the raas VM so that the web ui can be accessed from your host using the url: https://localhost
         if role == "sseraas"
            nodeconfig.vm.network "forwarded_port", guest: 443, guest_ip: properties['ip'], host: 443, host_ip: "127.0.0.1"
         end
         nodeconfig.vm.boot_timeout = 300
         # execute vm bootstrap
         nodeconfig.vm.provision "shell", path: "scripts/bootstrap.sh", args: [nodeFQDN, proxy]
         # update hosts file on each node with IP/FQDN for all machines in the group
         nodes.each do |r, p|
            fqdn = "#{p['hostname']}.#{domain}"
            nodeconfig.vm.provision "shell", inline: "sudo echo \"#{p['ip']}    #{fqdn}\">> /etc/hosts"
         end
         if role == "ssemaster"
            # for ssemaster, we setup a few more things, such as installing salt master & minion, adding the keys from all minions, then running highstate for the machines which need configured
            nodeconfig.vm.provision "shell", inline: "tar -xvf /vagrant/#{saltEnterpriseInstaller} -C /"
            nodeconfig.vm.provision "shell", inline: "rm -rf /srv/ && mv /sse_installer/ /srv/"
            nodeconfig.vm.provision "shell", inline: "yes | cp -f /vagrant/pillar-data/top.sls /srv/pillar/top.sls"
            nodeconfig.vm.provision "shell", inline: "yes | cp -f /vagrant/pillar-data/sse_settings.yaml /srv/pillar/sse/sse_settings.yaml"
            nodeconfig.vm.provision "shell", path: "scripts/setup-salt-master.sh", args: [nodeFQDN, ssemasterFQDN]
            nodeconfig.vm.provision "shell", inline: "sudo salt-key -A -y"
            # wait for minions to become responsive
            nodeconfig.vm.provision "shell", inline: "echo '@@ Wait for minion services to be ready ..'"
            nodeconfig.vm.provision "shell", path: "scripts/wait-for-minion.sh", args: ['*', 30, 10]
            # refresh pillar data on all minions
            nodeconfig.vm.provision "shell", inline: "echo '@@ Refresh pillar data ..'"
            nodeconfig.vm.provision "shell", inline: "sudo salt '*' saltutil.refresh_pillar"
            # run highstate on ssedb machines (this has to be done before the raas)
            nodes.each do |r, p|
               if r == "ssedb"
                  nodeconfig.vm.provision "shell", inline: "echo \"@@ Setup #{r} machine(s) ..\""
                  fqdn = "#{p['hostname']}.#{domain}"
                  nodeconfig.vm.provision "shell", path: "scripts/run-salt-highstate.sh", args: [fqdn, 5, 5]
               end
            end
            # run highstate on sseraas machines
            nodes.each do |r, p|
               if r == "sseraas"
                  nodeconfig.vm.provision "shell", inline: "echo \"@@ Setup #{r} machine(s) ..\""
                  fqdn = "#{p['hostname']}.#{domain}"
                  nodeconfig.vm.provision "shell", path: "scripts/run-salt-highstate.sh", args: [fqdn, 5, 5]
               end
            end
            # run highstate on master machines
            nodes.each do |r, p|
               if r == "ssemaster"
                  nodeconfig.vm.provision "shell", inline: "echo \"@@ Setup #{r} machine(s) ..\""
                  fqdn = "#{p['hostname']}.#{domain}"
                  nodeconfig.vm.provision "shell", path: "scripts/run-salt-highstate.sh", args: [fqdn, 5, 5]
                  nodeconfig.vm.provision "shell", inline: "salt-call --local service.restart salt-master"
               end
            end
         else
            # setup salt minion on all other VMs
            nodeconfig.vm.provision "shell", path: "scripts/setup-salt-minion.sh", args: [nodeFQDN, ssemasterFQDN]
         end
      end
   end
end
