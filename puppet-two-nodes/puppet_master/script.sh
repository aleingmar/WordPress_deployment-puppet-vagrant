#!/bin/bash
set -e

# Actualizar sistema y configurar hosts
sudo apt-get update -y

#copio el host al host del master
sudo cp /vagrant/puppetMaster/hosts /etc/hosts

# Instalar Puppet Server
wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get update -y
sudo apt-get install puppetserver -y

# Configuración del servidor Puppet
sudo rm -r /etc/puppetlabs/puppet/ssl/ #borro la capeta ssl por defecto
sudo cp /vagrant/puppetMaster/puppetServer /etc/default/puppetserver #copio el archivo de configuracion
sudo /opt/puppetlabs/bin/puppetserver ca setup --config /etc/puppetlabs/puppet/puppet.conf #arrancar el CA y creara sus certificados

# Arrancar Puppet Server
sudo systemctl start puppetserver
#verificar el estado del servicio
sudo systemctl enable puppetserver

#sudo /opt/puppetlabs/bin/puppetserver ca list --all #listar todos los certificados que tiene el master y que estan firmados
#sudo /opt/puppetlabs/bin/puppetserver ca sign --all #firmar todos los certificados pendientes que tiene el master