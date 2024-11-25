#!/bin/bash
set -e

# Actualizar sistema y configurar hosts
sudo apt-get update -y
sudo cp /vagrant/puppetClient/hosts /etc/hosts

# Instalar Puppet Agent
wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get update -y
sudo apt-get install puppet-agent -y

# Configuración del Puppet Agent
sudo cp /vagrant/puppetClient/puppet.conf /etc/puppetlabs/puppet/puppet.conf

# Configurar tarea cron para que el agente ejecute cada minuto, se ejecta en el cliente para pedir la configuracion en el master
echo "*/15 * * * * /opt/puppetlabs/bin/puppet agent --test" | sudo tee -a /var/spool/cron/crontabs/root
sudo chmod 600 /var/spool/cron/crontabs/root

# Arrancar Puppet Agent
sudo systemctl start puppet  #arrastrar el servicio, en este momento se envia la peticion al master de firmar su certificado, una vez firmado el master le pasaria la configuracion
sudo systemctl enable puppet  #verificar el estado del servicio

#sudo /opt/puppetlabs/bin/puppet agent --test