#Define el manifiesto principal del modulo de wordpress. Con este manifiesto se configura e instala wordpress en la mv.
#1. Instala, configura y arranca wordpress y administra una pagina web por defecto
#2. Configura e inicializa la bd de mysql para que wordpress pueda usarla
#3. Configura el servicio de apache para que redirija el tráfico al servicio de wordpress y sirva su contenido.

class wordpress {

  $wordpress_url = 'https://wordpress.org/latest.tar.gz' #link de descarga de wordpress
  $db_name     = lookup('mysql::db_name')
  $db_user     = lookup('mysql::db_user')
  $db_password = lookup('mysql::db_password')

  #################################### INSTALACION Y CONFIGURACION DE WORDPRESS

  # Descarga y extracción de WordPress el paquete  de code de wordpress se descarga en (/opt)
  exec { 'download-wordpress': #nombre de recurso
    command => "/usr/bin/wget -q -O /opt/wordpress.tar.gz ${wordpress_url}", #comando para descargar wordpress
    creates => '/opt/wordpress.tar.gz', # Evita descargarlo si ya existe 
    path    => '/usr/bin:/bin:/usr/sbin:/sbin', # Define las rutas para encontrar comando wget
    require => Package['apache2'], # Requiere Apache instalado
  }

  # Extraer WordPress en el directorio /var/www/html (directorio raíz de Apache por defecto)
  exec { 'extract-wordpress':
    command => '/bin/tar -xzvf /opt/wordpress.tar.gz -C /var/www/html',
    creates => '/var/www/html/wordpress', # Evita reextraer si el directorio ya existe
    require => Exec['download-wordpress'], # Depende de que el archivo de WordPress esté descargado
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar el comando tar
  }
  # Generar claves de autenticación para WordPress, que se utilizan para cifrar las cookies y las contraseñas y se important en el archivo de configuración de wordpress (wp-config.php)
  exec { 'generate-auth-keys':
    command => 'curl -s https://api.wordpress.org/secret-key/1.1/salt/ > /tmp/wp-keys.php',
    creates => '/tmp/wp-keys.php', # Solo lo genera si no existe
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
  }
  # Crear archivo de configuración de WordPress a partir del template
  file { '/var/www/html/wordpress/wp-config.php':
    ensure  => file,
    content => template('wordpress/wp-config.php.erb'),
    require => [Exec['generate-auth-keys'], Exec['extract-wordpress']],
}

  # Configurar permisos para WordPress
  exec { 'set-wordpress-permissions':
    command => '/bin/chown -R www-data:www-data /var/www/html/wordpress',
    require => Exec['extract-wordpress'], # Solo aplica los permisos si WordPress ya ha sido extraído
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar el comando chown
  }

  # Instalación de WP-CLI, herramienta de CLI para WordPress para configurar y administrar wordpress desde CLI 
  # Nosotros lo usamos para crear la estructura de la bd de wordpress
  exec { 'install-wp-cli':
    command => 'curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp',
    creates => '/usr/local/bin/wp', # Evita ejecutar si ya existe WP-CLI
    path    => '/usr/bin:/bin:/usr/sbin:/sbin', # Rutas donde buscar los comandos
    require => Exec['initialize-wordpress-db'], # Se asegura de que la base de datos ya esté configurada
}

  # Completar la instalación de WordPress (hasta ahora solo he creado la bd que va a usar y he instalado el paquete de wordpress)
  exec { 'wordpress-install':
    command => 'wp core install --url="http://localhost:8080" --title="Mi Sitio WordPress" --admin_user="admin" --admin_password="password" --admin_email="admin@example.com" --path=/var/www/html/wordpress --allow-root',
    path    => '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin', # Rutas donde buscar WP-CLI y otros comandos
    require => [File['/var/www/html/wordpress/wp-config.php'], Exec['install-wp-cli']], # Asegura wp-config.php y WP-CLI este instalado
  }

  #################################### CONFIGURAR CONTENIDO INICIAL DE WORDPRESS EN LA BD MYSQL
  # Script para insertar contenido inicial en WordPress
  file { '/etc/mysql/init-wordpress-content.sql':
    ensure  => present, # asegura que el fichero exista
    content => template('wordpress/init-wordpress-content.sql.erb'), # usa plantilla para rellenar el contenido del fichero
    require => Exec['wordpress-install'], # requiere que WordPress esté instalado
  }

  exec { 'initialize-wordpress-content':
    command => '/usr/bin/mysql < /etc/mysql/init-wordpress-content.sql', # ejecuta el script para añadir contenido
    unless  => "/usr/bin/mysql -e 'SELECT * FROM ${db_name}.wp_posts WHERE post_title=\"Bienvenido\";'", # evita ejecutar si ya existe el contenido
    require => File['/etc/mysql/init-wordpress-content.sql'], # requiere que el fichero exista
  }

############################################################33 CONFIGURAR APACHE PARA SERVIR WORDPRESS
  # Crear archivo de configuración de Apache para WordPress, antes de descargar wordpress nos aseguramos que estuviera instalado apache2
  file { '/etc/apache2/sites-available/wordpress.conf':
    ensure  => file, # Garantiza que sea un archivo
    content => template('wordpress/wp-apache-config.conf.erb'), # Usar plantilla para configurar el virtual host
    require => Exec['set-wordpress-permissions'], # Depende de que los permisos estén configurados
  }
  # Activar el sitio de WordPress en Apache
  exec { 'enable-wordpress-site':
    command => '/usr/sbin/a2ensite wordpress && /usr/bin/systemctl reload apache2',
    require => File['/etc/apache2/sites-available/wordpress.conf'], # Solo activa el sitio si existe la configuración
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar los comandos a2ensite y systemctl
  }
}
