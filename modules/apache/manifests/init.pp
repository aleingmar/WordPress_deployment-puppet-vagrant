# Este archivo `site.pp` define la clase `apache`, que especifica el estado deseado para la instalación,
# configuración y gestión del servidor Apache en la máquina virtual.
# La clase `apache` garantiza que Apache esté instalado y en ejecución, y que se configure correctamente
# mediante un host virtual que redirija a los archivos especificados. Esta configuración también elimina
# el archivo de configuración predeterminado de Apache para evitar conflictos, y reemplaza su funcionalidad
# con una configuración personalizada.
# Además, asegura que el archivo `index.html` esté disponible en el directorio raíz y que el servicio
# Apache se recargue automáticamente si hay cambios en los archivos de configuración.

# Define la clase `apache` que instala, configura y gestiona el servidor Apache. 
# Definiendo todos los recursos necesarios para ello (o la mayoria que sean generales ya que estan en un modulo de apache)
# (Los que sean muy personalizados se definen en el manifiesto principal)

class apache {
  
  # Actualiza la lista de paquetes disponibles en el sistema, para asegurarse de que Apache se instale correctamente.
  exec { 'apt-update':
    command => '/usr/bin/apt-get update'  # Ejecuta el comando `apt-get update`. (se indica directorio del binario del comando)
  }
  
  # Establece una dependencia, indicando que cualquier instalación de paquetes (Package) debe realizarse después de `apt-update`. (se ejecuta antes el exec de aptupdate)
  Exec["apt-update"] -> Package <| |>

  # Asegura que el paquete `apache2` esté instalado en el sistema.
  package { 'apache2':
    ensure => installed,  # Garantiza que el paquete de Apache esté presente en el sistema.
  }

  # Gestiona el servicio de Apache, asegurándose de que esté en ejecución y configurado para iniciarse al arrancar el sistema.
  service { 'apache2':
    ensure => running,  # Asegura que el servicio esté en ejecución.
    enable => true,  # Configura el servicio para iniciarse automáticamente con el sistema.
    hasstatus  => true,  # Permite a Puppet verificar el estado del servicio.
    restart => "/usr/sbin/apachectl configtest && /usr/sbin/service apache2 reload",  # Define el comando de reinicio para aplicar cambios.
  }
}


