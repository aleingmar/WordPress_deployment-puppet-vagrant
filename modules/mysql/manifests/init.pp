class mysql {

  # Instalación de MySQL
  package { 'mysql-server':
    ensure => installed,
  }

  # Aseguramos que el servicio de MySQL esté en ejecución
  service { 'mysql':
    ensure => running,
    enable => true,
  }

  # Configuración inicial de la base de datos de WordPress
  file { '/tmp/init-wordpress.sql':
    ensure  => present,
    content => template('mysql/init-wordpress.sql.erb'), # Plantilla SQL para inicializar WordPress (no hace falta poner tamplates, es el nombre que deberia tener)
    require => Package['mysql-server'],
  }

  exec { 'initialize-wordpress-db':
    command => '/usr/bin/mysql < /tmp/init-wordpress.sql',
    require => File['/tmp/init-wordpress.sql'],
  }
}
