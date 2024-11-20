## Teoría suelta explicada con mis palabras sobre Puppet

- Un **recurso** en puppet es todo elemento que va a servir para aprovisionar/configurar un servicio. 
    - Puede ser un fichero `file`, una ejecución de comando nativo en el SO base de la mv `exec`, un mensaje `message`...
    
- **Puppet agente** es el proceso que corre en cada uno de los nodos (mv/infra) que puppet se va a encargar de configurar
    - Depende de las necesidades puppet puede actuar con una arquitectura cliente-servidor con un proceso de puppet master (como servidor) o puede funcionar con una arquitectura sin puppet master (como es este caso).

- **Un modulo** no es más que la forma que tiene puppet de organizar todos los ficheros y elementos que se usan para la configuración de un servicio en concreto en una mv.
    - Por ejemplo en este caso, todo lo relacionado con configurar apache está en el modulo de apache. Si además tuvieramos que desplegar otro servicio dentro de la misma mv, tendriamos otro modulo llamado por ejemplo, my-sql, con todo lo relacionado con esa configuración
    - Normalmente se usan para ser reusados y no son muy personalizados para un despliegue en concreto, si no que configuran el aprovisionamiento de un servicio de forma general y ya cuando se llaman desde el manifiesto principal si se tiene que cambiar algo/personalizar para ese despliegue concreto se hace

- En los .pp por lo general el codigo fuente se ejecutan/compila de arriba hacia abajo siguiendo ese orden de ejecución, a no ser que haya recursos y sentencias de condiciones o ese tipo de cosas

- **Indicación:** Hay que saber instalar apache manualmente para saber hacerlo con puppet, ya que debemos saber indicarle el estado deseado, si no, es dificil saber indicarlo.


