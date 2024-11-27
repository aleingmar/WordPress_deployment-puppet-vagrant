#!/bin/bash

# Copiar el archivo de hosts
echo "Paso 1: Copiando el archivo de hosts"
sudo cp /vagrant/puppetClient/hosts /etc/hosts

# Actualizar sistema y convertir archivos al formato Unix
echo "Paso 2: Actualizando el sistema e instalando herramientas necesarias"
sudo apt-get update -y
sudo apt-get install -y dos2unix netcat
dos2unix /vagrant/puppetClient/*

# Instalar Puppet Agent
echo "Paso 3: Descargando e instalando Puppet Agent"
wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get update -y
sudo apt-get install puppet-agent -y

# Configurar Puppet Agent
echo "Paso 4: Configurando Puppet Agent"
sudo cp /vagrant/puppetClient/puppet.conf /etc/puppetlabs/puppet/puppet.conf

# Arrancar Puppet Agent
echo "Paso 5: Iniciando Puppet Agent y enviando solicitud al Master"
sudo systemctl start puppet #arrastrar el servicio, en este momento se envia la peticion al master de firmar su certificado, una vez firmado el master le pasaria la configuracion
sudo systemctl enable puppet #verificar el estado del servicio

# # Solicitar certificado al servidor
# echo "Solicitando certificado al Puppet Server..."
# sudo /opt/puppetlabs/bin/puppet agent --test || true  # Permitir que falle si el certificado aún no está firmado

# echo "Esperando a que el servidor firme el certificado..."
# while ! sudo /opt/puppetlabs/bin/puppet agent --test; do
#   echo "Intentando nuevamente en 5 segundos..."
#   sleep 5
# done

# echo "Configuración inicial del cliente completada."



# Configurar tarea cron para que el agente ejecute cada minuto, se ejecta en el cliente para pedir la configuracion en el master
# echo "*/15 * * * * /opt/puppetlabs/bin/puppet agent --test" | sudo tee -a /var/spool/cron/crontabs/root
# sudo chmod 600 /var/spool/cron/crontabs/root


#sudo /opt/puppetlabs/bin/puppet agent --test