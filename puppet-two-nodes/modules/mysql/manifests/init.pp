# Definimos el manifiesto principal del modulo de mysql. Con este manifiesto se configura e instala mysql en la mv.
# Se asegura de que el servicio de MySQL esté en ejecución y se configura la base de datos para iniciarizarla despues con wordpress

class mysql {

  # Variables para la configuración de la base de datos de WordPress
  $db_name     = lookup('mysql::db_name')
  $db_user     = lookup('mysql::db_user')
  $db_password = lookup('mysql::db_password')

  ####################################
  # Instalación de MySQL
  package { 'mysql-server':
    ensure => installed, # se asegura que el paquete esté instalado
  }

  # Aseguramos que el servicio de MySQL esté en ejecución
  service { 'mysql':
    ensure => running, # asegura que el servicio esté en ejecución
    enable => true, # se inicia automáticamente con el sistema
  }

  # Archivo de Configuración inicial de la base de datos para WordPress
  file { '/etc/mysql/init-wordpress.sql':
    ensure  => present, # asegura que el fichero exista
    content => template('mysql/init-wordpress.sql.erb'), # usa la plantilla para rellenar el contenido del fichero
    require => Package['mysql-server'], # requiere que MySQL esté instalado
  }

  # Ejecución del script de inicialización de la base de datos
  exec { 'initialize-wordpress-db': # nombre del recurso
    command => '/usr/bin/mysql < /etc/mysql/init-wordpress.sql', # ejecuta el script de inicialización
    unless  => "/usr/bin/mysql -e 'USE ${db_name};'", # si la base de datos existe, no ejecuta (evita que se vuelva a iniciar cuando se haga un vagrant provision) por ejemplo
    require => File['/etc/mysql/init-wordpress.sql'], # requiere que el fichero exista
  }
}

