# Este archivo `default.pp` es el manifiesto principal para configurar la máquina virtual (MV) con Puppet. (a partir de este se llaman a los modulos que se van a usar)
# Sirve como punto de entrada y contiene las configuraciones esenciales que Vagrant utiliza para aprovisionar la MV.
# Este manifiesto permite centralizar la configuración de Apache en un solo lugar, facilitando la personalización
# y el control sin necesidad de modificar directamente el módulo de Apache.

# Declara una variable para el directorio raíz de Apache
# (/vagrant es el directorio compartido donde se encuentra el Vagrantfile en la MV, (se crea por defecto por vagrant al lanzar la mv))
$document_root = '/vagrant'

# Include --> sirve para declarar los modulos que se van a usar en la configuración de esta mv
# Incluye el módulo de Apache, lo que permite instalar y configurar el servicio Apache en la MV.
include apache

# Ejecuta un comando condicionalmente para mostrar un mensaje solo si falta el archivo `index.html`.
# Este recurso es útil para comprobar si el archivo de inicio está presente en el directorio raíz.
exec { 'Skip Message': # Nombre del recurso Puppet
  command => "echo 'Este mensaje sólo se muestra si no se ha copiado el fichero index.html'",  # Comando a ejecutar si la condición `unless` no se cumple.
  unless  => "test -f ${document_root}/index.html",  # Solo se ejecuta si `index.html` no existe en `$document_root`.
  path    => "/bin:/sbin:/usr/bin:/usr/sbin",  # Define las rutas donde buscar los binarios necesarios para ejecutar el comando.(busca en /bin, busca en /usr/bin...), (puppet necesita que se defina con los exec)
}

# Declara una variable `$ipv4_address` que obtiene la IP de la MV.
# `$facts` es una variable global en Puppet que contiene información del sistema, como la red y el hardware.
$ipv4_address = $facts['networking']['ip']

# Muestra un mensaje con la información de la máquina, incluyendo la memoria y el número de procesadores,
# y proporciona la URL para acceder a Apache en la IP de la MV.
notify { 'Showing machine Facts':
  message => "Machine with ${::memory['system']['total']} of memory and ${::processorcount} processor/s.
              Please check access to http://${ipv4_address}",  # Muestra la IP para que el usuario verifique que el servidor Apache es accesible.
}
