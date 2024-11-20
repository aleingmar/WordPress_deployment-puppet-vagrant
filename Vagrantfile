# Configuración de Vagrant para la máquina virtual/entorno de infraestructura base virtual/IaC
# En este archivo se define la configuración básica de la MV en Vagrant:
#   - Se especifica la caja base (SO) de Ubuntu que se va a utilizar.
#   - Se configuran las opciones de red, incluyendo el redireccionamiento de puertos y la asignación de una IP privada.
#   - Se establece la memoria de la máquina virtual en 1024 MB.
#   - Se instala Puppet para gestionar y aprovisionar la configuración del servidor.
#   - Se instala puppet en modo agente para no depender de un servidor Puppet maestro.
#   - Se indica que Puppet usará el manifiesto `default.pp` y el módulo de configuración desde el directorio `modules`.

Vagrant.configure("2") do |config|  # Configura Vagrant con la versión 2 de su API.

  config.vm.box = "bento/ubuntu-22.04"  # Define la caja base de la MV; en este caso, Ubuntu 22.04 de Bento.

  # Redirecciona el puerto 80 de la MV al puerto 8080 del host, permitiendo acceder al servidor Apache desde el host.
  config.vm.network "forwarded_port", guest: 80, host: 8080
  
  # Asigna una IP privada específica a la MV para evitar conflictos o problemas de red con IPs asignadas por defecto.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Configura el proveedor de la MV, en este caso, VirtualBox.
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"  # Asigna 1024 MB de memoria RAM a la MV para un rendimiento adecuado.
  end

  # Instalación de Puppet mediante un aprovisionamiento con shell.
  # Aquí se ejecutan comandos de shell en la MV para descargar e instalar Puppet:
  #   - Descarga el paquete de Puppet para Ubuntu Bionic.
  #   - Actualiza la lista de paquetes y luego instala Puppet Agent.
  config.vm.provision "shell", inline: <<-SHELL
    sudo wget https://apt.puppetlabs.com/puppet6-release-bionic.deb  # Descarga el paquete de Puppet.
    sudo dpkg -i puppet6-release-bionic.deb  # Instala el paquete descargado.
    sudo apt-get update  # Actualiza la lista de paquetes.
    sudo apt-get install -y puppet-agent  # Instala Puppet Agent sin necesidad de un servidor Puppet maestro.
  SHELL

  # Configura Puppet como herramienta de aprovisionamiento en la MV.
  # Define que Puppet utilizará los módulos desde el directorio `modules` y el manifiesto `default.pp` desde `manifests`.
  config.vm.provision "puppet" do |puppet|
    puppet.module_path = "modules"        # Carpeta donde se almacenan los módulos de Puppet.
    puppet.manifests_path = "manifests"   # Carpeta que contiene los manifiestos de configuración.
    puppet.manifest_file = "default.pp"   # Archivo de manifiesto principal para aprovisionar la MV.
  end

end
