# -*- mode: ruby -*-
# vi: set ft=ruby :

$addExport = <<SCRIPT
if ! grep -Fxq "/exports/http 127.0.0.1(rw,sync,no_subtree_check)" /etc/exports ; then
  echo "/exports/http 127.0.0.1(rw,sync,no_subtree_check)" >> /etc/exports
fi
SCRIPT

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/trusty64'

  config.vm.provision :shell, inline: "mkdir -pm 0777 /exports/http"
  config.vm.provision :shell, inline: "mkdir -pm 0777 /srv/http-nfs"
  config.vm.provision :shell, inline: "apt-get -y install rpcbind nfs-kernel-server"
  config.vm.provision :shell, inline: $addExport
  config.vm.provision :shell, inline: "exportfs -ra"
  config.vm.provision :shell, inline: "service nfs-kernel-server restart"
  config.vm.provision :shell, inline: "mountpoint -q /srv/http-nfs || mount -vt nfs 127.0.0.1:/exports/http /srv/http-nfs"

  if Vagrant.has_plugin? 'vagrant-cachier'
    config.cache.scope = :box

    config.cache.enable :apt
    config.cache.enable :apt_lists
    config.cache.enable :apt_cacher
    config.cache.enable :composer
    config.cache.enable :bower
    config.cache.enable :npm
    config.cache.enable :gem
  end

  if Vagrant.has_plugin? 'vagrant-vbguest'
    config.vbguest.no_install = true
  end
end
