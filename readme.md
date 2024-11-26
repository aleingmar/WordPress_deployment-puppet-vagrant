## Automated deployment of Wordpress using Vagrant and Puppet

This project was developed for the Deployment Automation course, as part of the official university master's degree in Development and Operations (DevOps).

The main objective of this project is to automatically deploy a test web environment with a custom WordPress, using Vagrant as the Infrastructure as Code (IaC) tool and Puppet for automated provisioning. 
By simply running the `vagrant up` command in the terminal in the directory where the Vagrantfile is located, the entire environment is deployed without any additional configuration. 
Before deploying the configured WordPress environment, several provisioning and configuration tasks need to be performed:

1. prepare and configure the virtual machine (VM) with an Apache web server to redirect and serve all content.
2. Install the specific PHP modules required by WordPress.
3.	Configure a MySQL database that will be used by WordPress for its operation.

To verify correct operation, simply access `localhost:8080` from the browser.


The project includes two versions of the environment, organised in separate directories:

- `/puppet-two-nodes`.
This version deploys two Puppet nodes: a Puppet Master and a Puppet Client.

Each client (node) hosts a WordPress environment, provisioned with directives sent from the Puppet Master. Every min the puppet clients request the new puppet configuration if any via a cron job.
- `/puppet-one-node`
In this version, only one virtual machine (VM) is raised with a self-provisioning Puppet client, without the need for a Puppet Master.

### puppet-one-node Vagrantfile
The Vagrantfile defines the basic virtual machine (VM) configuration for creating an Infrastructure-as-Code (IaC) environment. It specifies the Ubuntu base box to be used, the networking options (including port forwarding and assigning a private IP), and allocates 1024 MB of RAM to the VM. In addition, Puppet is installed in agent mode, eliminating the need for a master Puppet server, and configured to use the main manifest `default.pp`, modules from the `modules` directory, and the Hiera configuration file `hiera.yaml` to centrally manage data.

### General structure of the puppet provisioning project

The organisation of the files and modules is detailed below, which makes it easier to understand the general functioning of the project:

- **Main file**: `manifests/default.pp`.
This file acts as the starting point for Puppet. The modules needed to configure all the components of the environment are imported from here. In this case, the code is split into three modules: **apache, mysql and wordpress**, which are executed and imported in this order. The PHP installation I have decided to code it directly in this module, without adding another module just for this as it is only 3 or 4 lines of code. The installation of these components is done in this order: **apache, php, mysql and wordpress**.

- **Variables management with Hiera**: `hiera.yaml, data/common.yaml`.
To manage variables, Hiera is used, which allows the keys to be separated from the source code. This ensures a more secure approach, as it avoids exposing sensitive credentials when uploading the project to a cloud repository. Although this project is academic and does not include encrypted variables, Hiera also offers the possibility to encrypt keys.
- Variables are declared along with their values in `data/common.yaml`.
- The `hiera.yaml` file configures how Hiera works.
- To integrate Hiera with Vagrant, the line `puppet.hiera_config_path = ‘hiera.yaml’` is added to the Vagrantfile.


- **Modules used**:
The project is divided into three main modules, which ensures modularity and organisation in the code:

1. **Apache module**.
This module provisions and configures the Apache web server in the VM, making it ready and active for the wordpress module to manage and serve content from it.

2. **mysql module**
In this module, a MySQL server is installed and configured on the VM, ensuring the correct functioning of the database manager. In addition, the database required for WordPress is created using the `init-wordpress.sql.erb` file.

3. **wordpress module**
This module installs and configures WordPress, making it fully functional. The main actions performed are:

- Installation of the wordpress packages and dependencies and activation of the service.
- Configuration of the `wp-config.conf.erb` file, which configures the service, among other things, connects WordPress with the database and defines previously generated access keys.
- Installation and use of the `wp-cli` tool to automate the configuration of the website.
- Initialisation of the database using the `init-wordpress-content.sql.erb` file with the minimum content necessary to launch a web page.
- Configuration of Apache to serve the page content, using the `wp-apache-config.conf.erb` file.


The service is accessible from the host at `localhost:8080` thanks to port 8080 redirection from the host to port 80 on the virtual machine, where Apache listens for incoming HTTP requests.

---------------------------------------------------------

## Despliegue automatizado de Wordpress usando Vagrant y Puppet

Este proyecto fue desarrollado para la asignatura de Automatización de Despliegues, como parte del máster universitario oficial en Desarrollo y Operaciones (DevOps).

El objetivo principal de este proyecto es desplegar de forma automática un entorno web de prueba con un WordPress personalizado, utilizando Vagrant como herramienta de Infraestructura como Código (IaC) y Puppet para su aprovisionamiento automatizado. 
Simplemente ejecutando en la terminal el comando `vagrant up` en el directorio donde se encuentra el Vagrantfile, se despliega todo el entorno sin necesidad de realizar configuraciones adicionales. 
Antes de desplegar el entorno WordPress configurado, es necesario llevar a cabo varias tareas de aprovisionamiento y configuración, entre ellas:

1.	Preparar y configurar la máquina virtual (MV) con un servidor web Apache para redirigir y servir todo el contenido.
2.	Instalar los módulos específicos de PHP requeridos por WordPress.
3.	Configurar una base de datos MySQL que será utilizada por WordPress para su funcionamiento.

Para verificar el correcto funcionamiento, basta con acceder a `localhost:8080` desde el navegador.


El proyecto incluye dos versiones del entorno, organizadas en directorios separados:

- `/puppet-two-nodes`
En esta versión se despliegan dos nodos Puppet: un Puppet Master y un Puppet Client.

Cada cliente (nodo) aloja un entorno de WordPress, aprovisionado con las directivas enviadas desde el Puppet Master. Cada min los puppet clients solicitan la nueva configuracon de pupet si la hubiera mediante una tarea cron.
- `/puppet-one-node`
En esta versión se levanta únicamente una máquina virtual (MV) con un cliente Puppet que se autoaprovisiona, sin necesidad de un Puppet Master.

### Vagrantfile de puppet-one-node
El Vagrantfile define la configuración básica de la máquina virtual (MV) para crear un entorno de infraestructura como código (IaC). Se especifica la caja base de Ubuntu que se utilizará, las opciones de red (incluyendo el redireccionamiento de puertos y la asignación de una IP privada), y se asigna 1024 MB de memoria RAM a la MV. Además, se instala Puppet en modo agente, eliminando la necesidad de un servidor Puppet maestro, y se configura para utilizar el manifiesto principal `default.pp`, los módulos desde el directorio `modules` y el archivo de configuración de Hiera `hiera.yaml` para gestionar datos de forma centralizada.

### Estructura general del proyecto de aprovisionamiento con puppet

A continuación, se detalla la organización de los archivos y módulos, lo que facilita la comprensión del funcionamiento general del proyecto:

- **Archivo principal**: `manifests/default.pp`
Este archivo actúa como el punto de inicio de Puppet. Desde aquí se importan los módulos necesarios para configurar todos los componentes del entorno. En este caso, el código está dividido en tres módulos: **apache, mysql y wordpress**, que son ejecutados e importados en este orden. La instalación de PHP he decidido codificarla directamente en este módulo, sin añadir un módulo más simplemente para esto ya que son apenas 3 o 4 líneas de código. La instalación de estos componentes se hace en este orden: **apache, php, mysql y wordpress**.

- **Gestión de variables con Hiera**: `hiera.yaml, data/common.yaml`
Para gestionar las variables, se utiliza Hiera, lo que permite separar las claves del código fuente. Esto asegura un enfoque más seguro, ya que evita exponer credenciales sensibles al subir el proyecto a un repositorio en la nube. Aunque este proyecto es académico y no incluye variables encriptadas, Hiera también ofrece la posibilidad de encriptar claves.
-	Las variables se declaran junto con sus valores en `data/common.yaml`.
-	El archivo `hiera.yaml` configura el funcionamiento de Hiera.
-	Para integrar Hiera con Vagrant, se añade la línea `puppet.hiera_config_path = "hiera.yaml"` en el Vagrantfile.


- **Módulos utilizados**:
El proyecto está dividido en tres módulos principales, lo que garantiza modularidad y organización en el código:

1. **Módulo apache**
Este módulo aprovisiona y configura el servidor web Apache en la MV, dejándolo preparado y activo para que el módulo wordpress pueda administrar y servir contenido desde él.

2. **Módulo mysql**
En este módulo se instala y configura un servidor MySQL en la MV, asegurando el correcto funcionamiento del gestor de bases de datos. Además, se crea la base de datos necesaria para WordPress mediante el archivo `init-wordpress.sql.erb`

3. **Módulo wordpress**
Este módulo instala y configura WordPress, dejándolo completamente funcional. Las principales acciones realizadas son:

-	Instalación de los paquetes y dependencias de Wordpress y activación del servicio.
-	Configuración del archivo `wp-config.conf.erb`, que configura el servicio, entre otras cosas, conecta WordPress con la base de datos y define claves de acceso generadas previamente.
-	Instalación y uso de la herramienta `wp-cli` para automatizar la configuración del sitio web.
-	Inicialización de la base de datos mediante el archivo `init-wordpress-content.sql.erb` con un contenido mínimo necesario para lanzar una página web.
-	Configuración de Apache para servir el contenido de la página, utilizando el archivo `wp-apache-config.conf.erb`.


El servicio es accesible desde el host en `localhost:8080` gracias a la redirección del puerto 8080 del host al puerto 80 de la máquina virtual, donde Apache escucha las solicitudes HTTP entrantes.


