#!/bin/bash

#copio el host al host del master
echo "Paso 1: Copiando el archivo de hosts al host del master"
sudo cp /vagrant/puppetMaster/hosts /etc/hosts

# Actualizar el sistema y convertir archivos al formato Unix
echo "Paso 2: Actualizando el sistema e instalando herramientas necesarias"
sudo apt-get update -y
sudo apt-get install -y dos2unix
dos2unix /vagrant/puppetMaster/*

# Instalar Puppet Server
echo "Paso 3: Descargando e instalando Puppet Server"
wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get update -y
sudo apt-get install puppetserver -y

# Configurar y arrancar Puppet Server
echo "Paso 4: Configurando Puppet Server"
sudo rm -r /etc/puppetlabs/puppet/ssl/ #borro la capeta ssl por defecto
sudo cp /vagrant/puppetMaster/puppetServer /etc/default/puppetserver #copio el archivo de configuracion
sudo /opt/puppetlabs/bin/puppetserver ca setup --config /etc/puppetlabs/puppet/puppet.conf #arrancar el CA y creara sus certificados

# Arrancar Puppet Server
echo "Paso 5: Iniciando Puppet Server"
sudo systemctl start puppetserver
sudo systemctl enable puppetserver #verificar el estado del servicio

# Meter el contenido de los modulos y los manifests en la carpeta de produccion, carpeta desde donde el master va a leer la configuracion que le va a enviar al cliente
echo "Paso 6: Meter el contenido de los modulos y los manifests en la carpeta de produccion"
sudo cp -r /vagrant/modules/* /etc/puppetlabs/code/environments/production/modules/
sudo cp /vagrant/manifests/default.pp /etc/puppetlabs/code/environments/production/manifests/default.pp
sudo cp /vagrant/hiera.yaml /etc/puppetlabs/code/environments/production/hiera.yaml
sudo cp -r /vagrant/data/* /etc/puppetlabs/code/environments/production/data/






#sudo /opt/puppetlabs/bin/puppetserver ca list --all #listar todos los certificados que tiene el master y que estan firmados
#sudo /opt/puppetlabs/bin/puppetserver ca sign --all #firmar todos los certificados pendientes que tiene el master

# # Esperar solicitudes de certificado del cliente
# echo "Esperando solicitudes de certificados de los clientes..."
# while true; do
#   CERT_REQUESTS=$(sudo /opt/puppetlabs/bin/puppetserver ca list --all | grep "Requested")
#   if [[ ! -z "$CERT_REQUESTS" ]]; then
#     echo "Certificados encontrados. Firmando..."
#     sudo /opt/puppetlabs/bin/puppetserver ca sign --all
#     break
#   else
#     echo "No hay solicitudes de certificados. Reintentando en 5 segundos..."
#     sleep 5
#   fi
# done

# # Configurar manifests para el cliente
# cat <<EOL | sudo tee /etc/puppetlabs/code/environments/production/manifests/site.pp
# node 'puppetclient' {
#    file { '/newfolder':
#       ensure => 'directory',
#    }

#    file { '/newfolder/hola.txt':
#       ensure => present,
#    }
# }
# EOL

# echo "Puppet Server configurado correctamente."