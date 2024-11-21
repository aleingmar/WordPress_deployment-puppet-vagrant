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
    ensure => installed, # se asegura que el paquete esté instalado
  }

  # Aseguramos que el servicio de MySQL esté en ejecución
  service { 'mysql':
    ensure => running, # asegura que el servicio esté en ejecución
    enable => true, # se inicia automáticamente con el sistema
  }

  # Configuración inicial de la base de datos para WordPress
  file { '/etc/mysql/init-wordpress.sql':
    ensure  => present, # asegura que el fichero exista
    content => template('mysql/init-wordpress.sql.erb'), # usa la plantilla para rellenar el contenido del fichero
    require => Package['mysql-server'], # requiere que MySQL esté instalado
  }

  # Ejecución del script de inicialización de la base de datos
  exec { 'initialize-wordpress-db': # nombre del recurso
    command => '/usr/bin/mysql < /etc/mysql/init-wordpress.sql', # ejecuta el script de inicialización
    unless  => "/usr/bin/mysql -e 'USE ${db_name};'", # si la base de datos existe, no ejecuta
    require => File['/etc/mysql/init-wordpress.sql'], # requiere que el fichero exista
  }

  ####################################
  # Instalación de WP-CLI
  exec { 'install-wp-cli':
    command => 'curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp',
    creates => '/usr/local/bin/wp', # Evita ejecutar si ya existe WP-CLI
    path    => '/usr/bin:/bin:/usr/sbin:/sbin', # Rutas donde buscar los comandos
    require => Exec['initialize-wordpress-db'], # Se asegura de que la base de datos ya esté configurada
}

  # Completar la instalación de WordPress
  exec { 'wordpress-install':
    command => 'wp core install --url="http://localhost:8080" --title="Mi Sitio WordPress" --admin_user="admin" --admin_password="password" --admin_email="admin@example.com" --path=/var/www/html/wordpress --allow-root',
    path    => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin', # Rutas donde buscar WP-CLI y otros comandos
    require => [File['/var/www/html/wordpress/wp-config.php'], Exec['install-wp-cli']], # Asegura wp-config.php y WP-CLI
  }

  ####################################
  # Script para insertar contenido inicial en WordPress
  file { '/etc/mysql/init-wordpress-content.sql':
    ensure  => present, # asegura que el fichero exista
    content => template('mysql/init-wordpress-content.sql.erb'), # usa plantilla para rellenar el contenido del fichero
    require => Exec['wordpress-install'], # requiere que WordPress esté instalado
  }

  exec { 'initialize-wordpress-content':
    command => '/usr/bin/mysql < /etc/mysql/init-wordpress-content.sql', # ejecuta el script para añadir contenido
    unless  => "/usr/bin/mysql -e 'SELECT * FROM ${db_name}.wp_posts WHERE post_title=\"Bienvenido\";'", # evita ejecutar si ya existe el contenido
    require => File['/etc/mysql/init-wordpress-content.sql'], # requiere que el fichero exista
  }
}

