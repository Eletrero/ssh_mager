# ssh_mager para (Ubuntu 25.10)

Este proyecto es un script de Bash diseñado para gestionar conexiones SSH de forma rápida y visual en entornos Linux (específicamente probado en Ubuntu 25.10). Permite realizar túneles mediante ADB (Cable USB) o conexiones directas por Wi-Fi, con soporte para persistencia de datos y llaves de seguridad.
🚀 Características

    Conexión Dual: Soporte para dispositivos mediante cable (ADB) y red inalámbrica.

    Auto-Guardado: Almacena tus credenciales (IP, usuario, puerto) en un archivo local para evitar reescritura. (solo si la coneccion fue exitosa)

    Seguridad: Opción integrada para generar y copiar llaves SSH (ed25519) y entrar sin contraseña. (explicado al final del documento en *Nota de seguridad*)

    Interfaz Colorida: Colores ANSI para una mejor experiencia de usuario en la terminal.

    Sistema de Errores: Diccionario de errores estandarizado para facilitar el soporte.

--------------------------------------------------------------------------------------------------
🛠️ Requisitos previos

Antes de ejecutar el script, asegúrate de tener instaladas las siguientes dependencias en tu sistema Ubuntu:

    sudo apt update
    sudo apt install android-tools-adb openssh-client
--------------------------------------------------------------------------------------------------

Nota: *El dispositivo remoto (teléfono o servidor) debe tener un servidor SSH activo. Si es un teléfono Android, puedes usar Termux , linux deploid(necesita root) 0 apps similares.*

--------------------------------------------------------------------------------------------------
📋 Diccionario de Errores

Si encuentras un problema durante la ejecución, el script lanzará un código de error. Consulta esta tabla para saber qué hacer:

    Código	Color   Significado  	        Solución Sugerida

    ERR-01	Rojo	  Fallo de ADB	        Revisa el cable USB y que la "Depuración USB" esté activa en el móvil.

    ERR-02	Rojo    Fallo de SSH	        Verifica que el servidor SSH esté corriendo en el dispositivo y que la IP/Puerto sean correctos.

    ERR-03	Rojo	  Datos Vacíos	        No hay conexiones guardadas. Debes crear una nueva primero (Opción 1 o 2).

    ERR-04	Rojo	  Selección Inválida	  Elegiste un número de menú que no existe en la lista.

    ERR-05	Rojo	  Error de Escritura	  Revisa los permisos del archivo ~/.ssh_conexiones.txt.

--------------------------------------------------------------------------------------------------

⚙️ Instalación y Uso

    1.Clonar o copiar el script: Guarda el código en un archivo llamado ssh-manager.sh

    2.Dar permisos de ejecución:
    chmod +x ssh-manager.sh

    3.Ejecutar:
    ./ssh-manager.sh
    
  --------------------------------------------------------------------------------------------------
    
  o se puede modificar el bash para poder agregar el comando "ssh-manager" y ejecutar en cualquier lugar de la terminal sin tener que moverte entre directorio.

    1.Clonar o copiar el script: Guarda el código en un archivo llamado ssh-manager.sh en el directorio //home/tu-usuario/.ssh-manager.
    mkdir ~/.ssh-manager
    Aqui clonaras en archivo ssh-manager.sh y le daras permiso de ejecucion
    chmod +x ~/.ssh-manager/ssh-manager.sh
    
    2.Editar bash 
    nano ~/.bashrc
    
    3.Ve al final del archivo y añade la siguiente línea:
    alias ssh-manager='/home/tu-usuario/.ssh-manager/ssh-manager.sh'
    
    4.Guarda y sal, Control + X , S , Enter
    
    5.Actualiza tu terminal actual: Para que Ubuntu reconozca el cambio de inmediato sin cerrar la sesión, ejecuta:
    source ~/.bashrc
    
  --------------------------------------------------------------------------------------------------

💡 Tips para Desarrolladores

    Puerto Simétrico: Para las conexiones ADB, el script utiliza el mismo puerto local y remoto ($pl <-> $pl) para asegurar compatibilidad con servidores configurados en puertos no estándar.

    Persistencia: Los datos se guardan en ~/.ssh_conexiones.txt. Puedes editar este archivo manualmente si necesitas borrar una entrada antigua
    
    1. Nota de seguridad
     *La contraseña que escribes en la opcion 4 nunca se escribe en ~/.ssh_conexiones.txt. Cuando el script ejecuta el comando ssh, es el propio sistema operativo Ubuntu el que te pide la contraseña en tiempo real. Esto evita que, si alguien te roba el archivo de texto, pueda entrar a tu teléfono.*
    
    2. El Agente de SSH (SSH Agent)
    En Ubuntu, existe un programa en segundo plano llamado ssh-agent. Si tu llave privada tuviera una contraseña (passphrase), el agente la guarda temporalmente en la memoria RAM mientras tu sesión esté iniciada, para que no tengas que escribirla cada cinco minutos.

    3.¿Qué pasa si quiero que se guarden de forma automática?
    Como programador, verás que existen herramientas como sshpass, que permiten enviar la contraseña automáticamente. Sin embargo, no te lo recomiendo, ya que dejarías la contraseña escrita en el código o en un archivo, lo cual es un riesgo de seguridad grave (un "Bad Practice").
