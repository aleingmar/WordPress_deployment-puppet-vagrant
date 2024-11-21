# Definimos el manifiesto principal del modulo de mysql. Con este manifiesto se configura e instala mysql en la mv.
# Se asegura de que el servicio de MySQL esté en ejecución y se configura la base de datos para usarla con WordPress con los datos de configuración que se pasan como variables.

class mysql {

  # Variables para la configuración de la base de datos de WordPress
  $db_name     = 'wordpress'
  $db_user     = 'wordpressuser'
  $db_password = 'securepassword123'
  ####################################

  # Instalación de MySQL
  package { 'mysql-server':
    ensure => installed, #se asegura que el paquete este instalado
  }

  # Aseguramos que el servicio de MySQL esté en ejecución
  service { 'mysql':
    ensure => running, #asegura que el servicio este en ejecución
    enable => true, #se inicia automaticamente con el sistema
  }

  # Configuración inicial de la base de datos para usarla con WordPress --> script de inicializacion de la bd
  file { '/etc/mysql/init-wordpress.sql':
    ensure  => present, #se asegura que exista el fichero
    content => template('mysql/init-wordpress.sql.erb'), # Usa esta plantilla para rellenar el contenido del fichero (no hace falta poner tamplates, es el nombre que deberia tener)
    require => Package['mysql-server'],
  }

  #Ejecución del script de inicialización de la base de datos
  exec { 'initialize-wordpress-db': #nombre del recurso
    command => '/usr/bin/mysql < /etc/mysql/init-wordpress.sql', #ejecuta el script usando el cliente (/usr/bin/mysql)
    unless => "/usr/bin/mysql -e 'USE ${db_name};'", # se existe ya la bd no se ejecuta
    require => File['/etc/mysql/init-wordpress.sql'], #requiere que el fichero exista
  }
}
