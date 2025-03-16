#!/bin/bash

sed -i 's/\r$//' ./configuracion/cambiar_user_grupo.sh

source "./variables/variables_ftp.sh"
source "./entrada/menu_ftp.sh"
source "./entrada/solicitar_user.sh"
source "./entrada/solicitar_grupo.sh"
source "./configuracion/crear_user.sh"
source "./configuracion/cambiar_user_grupo.sh"
source "./configuracion/conf_certSSL.sh"
source "./configuracion/conf_ftp.sh"

# SCRIPT PARA EJECUTAR FTP

if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root" 
    exit 1
fi

conf_ftp "$VSFTPD_CONF" "$FTP_ROOT"

echo "--- CONFIGURACIÓN SERVIDOR FTP - ANDREA CASTELLANOS ---"

if [ ! -f "/etc/ssl/private/vsftpd.pem" ]; then
    while true; do
        echo "¿Desea configurar su servidor FTP con certificado SSL? 1 - Sí, 2 - No"
        read -p "Opción: " op

        if [ "$op" == "1" ]; then
            conf_certSSL
            break
        elif [ "$op" == "2" ]; then
            echo "Configuración sin certificado SSL"
            break
        else
            echo "Opción no válida. Intenta de nuevo..."
        fi
    done
else 
    echo "El servidor FTP ya ha sido previamente configurado con certificado SSL."
fi

while true; do
    echo "1. Crear usuario"
    echo "2. Cambiar un usuario de grupo"
    echo "3. Salir"
    read -p "Elija la opción que desea realizar (1-3): " opc

    if [ "$opc" -eq "1" ]; then
        echo "Ingresa el nombre de usuario:"
        FTP_USER=$(solicitar_user)
        if [ -z "$FTP_USER" ]; then
            echo "Regresando a menú principal..."
            continue
        fi
        echo "Seleccione el grupo (1: Reprobados, 2: Recursadores):"
        FTP_GROUP=$(solicitar_grupo)
        if [ -z "$FTP_GROUP" ]; then
            echo "Regresando a menú principal..."
            continue
        fi
        crear_user "$FTP_USER" "$FTP_GROUP"
        echo "Configuración completa. Prueba acceder con un cliente FTP."
    elif [ "$opc" -eq "2" ]; then
        cambiar_user_grupo
    elif [ "$opc" -eq "3" ]; then
        echo "Saliendo..."
        exit 0
    else
        echo "Opción no válida. Intente de nuevo."
    fi
done

