# Este archivo `default.pp` es el manifiesto principal para configurar la máquina virtual (MV) con Puppet.
# Sirve como punto de entrada y contiene las configuraciones esenciales que Vagrant utiliza para aprovisionar la MV.
# Este manifiesto permite centralizar la configuración de Apache en un solo lugar, facilitando la personalización
# y el control sin necesidad de modificar directamente el módulo de Apache.

# Declara una variable para el directorio raíz de Apache
# (/vagrant es el directorio compartido donde se encuentra el Vagrantfile en la MV, (se crea por defecto por vagrant al lanzar la mv))
$document_root = '/vagrant'

# Instalación en la MV de PHP normal y librerías necesarias para que apps escritas en PHP interactúen con BD MySQL
package { ['php', 'php-mysql']:
  ensure  => installed,
  require => Package['apache2'], # Requiere Apache instalado, ya que PHP necesita integrarse con Apache
}

############################################# INCLUSIÓN DE MÓDULOS
# Incluye el módulo de Apache, lo que permite instalar y configurar el servicio Apache en la MV.
include apache

# Incluye el módulo de MySQL, lo que permite instalar y configurar el servicio MySQL en la MV.
include mysql

# Incluye el módulo de WordPress (se pone después de PHP, MySQL y Apache para que se instale después de estos, ya que depende de ellos)
include wordpress
#############################################

# Declara una variable `$ipv4_address` que obtiene la IP de la MV.
# `$facts` es una variable global en Puppet que contiene información del sistema, como la red y el hardware.
$ipv4_address = $facts['networking']['ip']

# Muestra un mensaje con la información de la máquina, incluyendo la memoria y el número de procesadores,
# y proporciona la URL para acceder a Apache en la IP de la MV.
notify { 'Showing machine Facts':
  message => "Machine with ${::memory['system']['total']} of memory and ${::processorcount} processor/s.
              Please check access to http://${ipv4_address}",  # Muestra la IP para que el usuario verifique que el servidor Apache es accesible.
}
