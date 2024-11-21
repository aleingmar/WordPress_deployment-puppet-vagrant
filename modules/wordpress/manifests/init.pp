#Define el manifiesto principal del modulo de wordpress. Con este manifiesto se configura e instala wordpress en la mv.
#Se asegura de que el servicio de wordpress este en ejecución y se configura
# para que apache redirija el tráfico al servicio de wordpress.

class wordpress {

  $wordpress_url = 'https://wordpress.org/latest.tar.gz' #link de descarga de wordpress
  $db_name         = 'wordpress'
  $db_user         = 'wordpressuser'
  $db_password     = 'securepassword123'
  $auth_key        = 'GENERATE_YOUR_KEY'
  $secure_auth_key = 'GENERATE_YOUR_KEY'
  $logged_in_key   = 'GENERATE_YOUR_KEY'
  $nonce_key       = 'GENERATE_YOUR_KEY'
  $auth_salt       = 'GENERATE_YOUR_KEY'
  $secure_auth_salt = 'GENERATE_YOUR_KEY'
  $logged_in_salt  = 'GENERATE_YOUR_KEY'
  $nonce_salt      = 'GENERATE_YOUR_KEY'

  
  # Descarga y extracción de WordPress
  exec { 'download-wordpress': #nombre de recurso
    command => "/usr/bin/wget -q -O /opt/wordpress.tar.gz ${wordpress_url}", #comando para descargar wordpress
    creates => '/opt/wordpress.tar.gz', # Evita descargarlo si ya existe 
    path    => '/usr/bin:/bin:/usr/sbin:/sbin', # Define las rutas para encontrar comando wget
    require => Package['apache2'], # Requiere Apache instalado
  }


  # Extraer WordPress en el directorio /var/www/html
  exec { 'extract-wordpress':
    command => '/bin/tar -xzvf /opt/wordpress.tar.gz -C /var/www/html',
    creates => '/var/www/html/wordpress', # Evita reextraer si el directorio ya existe
    require => Exec['download-wordpress'], # Depende de que el archivo de WordPress esté descargado
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar el comando tar
  }

  # Crear archivo de configuración de WordPress a partir del template
  file { '/var/www/html/wordpress/wp-config.php':
  ensure  => file,
  content => template('wordpress/wp-config.php.erb'),
  require => Exec['extract-wordpress'],
  }

  # Configurar permisos para WordPress
  exec { 'set-wordpress-permissions':
    command => '/bin/chown -R www-data:www-data /var/www/html/wordpress',
    require => Exec['extract-wordpress'], # Solo aplica los permisos si WordPress ya ha sido extraído
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar el comando chown
  }

############################################################33
  # Crear archivo de configuración de Apache para WordPress, antes de descargar wordpress nos aseguramos que estuviera instalado apache2
  file { '/etc/apache2/sites-available/wordpress.conf':
    ensure  => file, # Garantiza que sea un archivo
    content => template('wordpress/wordpress.conf.erb'), # Usar plantilla para configurar el virtual host
    require => Exec['set-wordpress-permissions'], # Depende de que los permisos estén configurados
  }
##############################################################
  # Activar el sitio de WordPress en Apache
  exec { 'enable-wordpress-site':
    command => '/usr/sbin/a2ensite wordpress && /usr/bin/systemctl reload apache2',
    require => File['/etc/apache2/sites-available/wordpress.conf'], # Solo activa el sitio si existe la configuración
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar los comandos a2ensite y systemctl
  }
}
