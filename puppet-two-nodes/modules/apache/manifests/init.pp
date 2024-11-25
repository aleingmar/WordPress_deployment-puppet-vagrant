# Este archivo `init.pp` define la clase `apache`, que especifica el estado deseado para la instalación,
# configuración y gestión del servidor Apache en la máquina virtual.
# La clase `apache` garantiza que Apache esté instalado y en ejecución. Esta configuración también elimina
# el archivo de configuración predeterminado de Apache para evitar conflictos con wordpress.
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
  # Elimina la configuración predeterminada para evitar conflictos
  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent, # Asegura que este archivo no esté presente
    require => Package['apache2'], # Solo después de instalar Apache
    notify  => Service['apache2'], # Notifica a Apache para recargar la configuración -> salta el restart
  }

  # Deshabilita el sitio predeterminado mediante el comando `a2dissite`
  exec { 'disable-default-site':
    command => '/usr/sbin/a2dissite 000-default',
    onlyif  => '/bin/ls /etc/apache2/sites-enabled/000-default.conf', # Solo si el sitio predeterminado está habilitado
    require => Package['apache2'], # Requiere que Apache esté instalado
    notify  => Service['apache2'], # Notifica a Apache para recargar la configuración salta el restart
    path    => '/usr/bin:/bin:/usr/sbin:/sbin', # Define las rutas para encontrar los comandos
  }
  # Gestiona el servicio de Apache, asegurándose de que esté en ejecución y configurado para iniciarse al arrancar el sistema.
  service { 'apache2':
    ensure => running,  # Asegura que el servicio esté en ejecución.
    enable => true,  # Configura el servicio para iniciarse automáticamente con el sistema.
    hasstatus  => true,  # Permite a Puppet verificar el estado del servicio.
    restart => "/usr/sbin/apachectl configtest && /usr/sbin/service apache2 reload",  # Define el comando de reinicio para aplicar cambios, cuando salta un notify.
  }
}


