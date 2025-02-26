#!/bin/bash

#Importar funciones de lectura
source "./funciones/bash/configuracion/conf_ftp.sh"
source "./funciones/bash/entrada/solicitar_user.sh"
source "./funciones/bash/entrada/solicitar_grupo.sh"
source "./funciones/bash/entrada/solicitar_psswd.sh"
source "./funciones/bash/configuracion/cambiar_user_grupo.sh"

while true; do
    echo "--- BIENVENIDO A LA CONFIGURACIÓN DE SU SERVIDOR FTP ---"
    echo "1. Crear usuario"
    echo "2. Cambiar a un usuario de grupo"
    echo "3. Salir"
    echo "Seleccione una opción (1-3):"
    read opc

    case $opc in
        1)
            echo "--- CREAR USUARIO ---"
            user=$(solicitar_user)
            ;;
        2)  
            echo "--- CAMBIAR DE GRUPO A USUARIO ---"
            cambiar_user_grupo
            ;;
        *)
            echo "OPCIÓN INVÁLIDA"
            ;;
    esac
done


