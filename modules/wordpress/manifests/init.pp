class wordpress {

  # Descarga y extracción de WordPress
  exec { 'download-wordpress':
    command => '/usr/bin/wget -q -O /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz',
    creates => '/tmp/wordpress.tar.gz', # Evita descargarlo si ya existe
    path    => '/usr/bin:/bin:/usr/sbin:/sbin', # Define las rutas para encontrar comandos
    require => Package['apache2'], # Requiere Apache instalado
  }


  # Extraer WordPress en el directorio /var/www/html
  exec { 'extract-wordpress':
    command => '/bin/tar -xzvf /tmp/wordpress.tar.gz -C /var/www/html',
    creates => '/var/www/html/wordpress', # Evita reextraer si el directorio ya existe
    require => Exec['download-wordpress'], # Depende de que el archivo de WordPress esté descargado
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar el comando tar
  }

  # Configurar permisos para WordPress
  exec { 'set-wordpress-permissions':
    command => '/bin/chown -R www-data:www-data /var/www/html/wordpress',
    require => Exec['extract-wordpress'], # Solo aplica los permisos si WordPress ya ha sido extraído
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar el comando chown
  }

  # Crear archivo de configuración de Apache para WordPress
  file { '/etc/apache2/sites-available/wordpress.conf':
    ensure  => file, # Garantiza que sea un archivo
    content => template('wordpress/wordpress.conf.erb'), # Usar plantilla para configurar el virtual host
    require => Exec['set-wordpress-permissions'], # Depende de que los permisos estén configurados
  }

  # Activar el sitio de WordPress en Apache
  exec { 'enable-wordpress-site':
    command => '/usr/sbin/a2ensite wordpress && /usr/bin/systemctl reload apache2',
    require => File['/etc/apache2/sites-available/wordpress.conf'], # Solo activa el sitio si existe la configuración
    path    => '/bin:/usr/bin:/sbin:/usr/sbin', # Rutas para encontrar los comandos a2ensite y systemctl
  }
}
