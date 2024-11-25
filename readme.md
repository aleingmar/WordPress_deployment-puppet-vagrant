## PROYECTO

Este proyecto fue desarrollado como parte de la asignatura "Herramientas de Automatización de Despliegues" del máster oficial en Desarrollo y Operaciones (DevOps) de la UNIR.
El objetivo principal es desplegar automáticamente un entorno web de prueba con un WordPress personalizado utilizando Vagrant como herramienta de Infraestructura como Código (IaC) y Puppet para su aprovisionamiento automatizado. Simplemente ejecutando en la terminal `vagrant up` en el directorio donde esta situado el vagrantfile y todo se despliega sin tener que hacer nada más. Para comprobarlo se accede a localhost:8080 desde el navegador.

### Descripción del proyecto
Antes de desplegar el entorno WordPress configurado, es necesario realizar varias tareas de aprovisionamiento y configuración:

1. Preparar y configurar la máquina virtual (MV) de un servidor web Apache para redirigir y servir todo el contenido.
2. Instalar módulos específicos de PHP requeridos por WordPress.
3. Configurar una base de datos MySQL que será utilizada por WordPress para su funcionamiento.

### Versiones disponibles
El proyecto incluye dos versiones del entorno, organizadas en directorios separados:

- `/puppet-two-nodes`
En esta versión se despliegan dos nodos Puppet: un Puppet Master y un Puppet Client.

Cada cliente (nodo) aloja un entorno de WordPress, aprovisionado con las directivas enviadas desde el Puppet Master. Cada min los puppet clients solicitan la nueva configuracon de pupet si la hubiera mediante una tarea cron.
- `/puppet-one-node`
En esta versión se levanta únicamente una máquina virtual (MV) con un cliente Puppet que se autoaprovisiona, sin necesidad de un Puppet Master.

### Estructura del proyecto de puppet
Para comprender el funcionamiento general del proyecto, a continuación se describe la organización de los archivos y módulos:

- **Archivo principal**: `manifests/default.pp`
Este archivo actúa como el punto de inicio de Puppet. Desde aquí se importan los módulos necesarios para configurar todos los componentes del entorno.

- **Gestión de variables**: 
Para gestionar las variables usamos **Hiera**, una funcionalidad que me sirve para poder separar las claves del propio codigo fuente. Esto me permite llevar unas practicas mucho mas seguras, por ejemplo subir a un repositorio en la nube todo el contenido fuente y no las claves o incluso esta funcionalidad tiene la posibilidad de poder gestionar estas variables encriptandolas con claves. (al ser un proyecto academico no llegamos a eso).
Las variables se declaran junto a sus valores en `data/common.yaml`, con el fichero `hiera.yaml` configuramos hiera para su funcionamienta y para que vagrant sepa que se va a usar hiera para la distribucion de datos se añade esta linea al vagrantfile `puppet.hiera_config_path = "hiera.yaml"`.


- **Módulos utilizados**:
El proyecto está dividido en tres módulos principales para garantizar una mayor modularidad y organización del código:

1. Módulo apache
Este módulo aprovisiona y configura el servidor web Apache en la MV. Deja el servidor preparado para que el módulo wordpress pueda administrar y servir contenido desde él.

2. Módulo mysql
Aquí se instala y configura un servidor MySQL en la MV, asegurando que el gestor de bases de datos funcione correctamente. Además, se crea la base de datos que será utilizada por WordPress `init-wordpress.sql.erb`

3. Módulo wordpress
Este módulo instala y configura WordPress hasta dejarlo completamente funcional.

- Se instalan los paquetes necesarios y se activa el servicio.
- Con el fichero `wp-config.conf.erb` se configura el servicio (se conecta wordpress con la bd, se importan las claves de acceso generadas ...) y con la herramienta `wp-cli`, se consigue la configuración del sitio web.
- Se inicializa la bd con contenido necesario para wordpress `init-wordpress-content.sql.erb`
- Se configura Apache para que sirva el contenido del sitio `wp-apache-config.conf.erb`


