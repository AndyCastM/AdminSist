#!/bin/bash

sed -i 's/\r$//' ./configuracion/cambiar_user_grupo.sh

source "./entrada/menu_ftp.sh"
source "./entrada/solicitar_user.sh"
source "./entrada/solicitar_grupo.sh"
source "./configuracion/crear_user.sh"
source "./configuracion/cambiar_user_grupo.sh"
source "./configuracion/conf_ftp.sh"

# SCRIPT PARA EJECUTAR FTP

if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root" 
    exit 1
fi

# Variables principales
FTP_ROOT="/home/ftp"
PUBLIC_DIR="$FTP_ROOT/publica"
USERS_DIR="$FTP_ROOT/users"
GROUPS_DIR="$FTP_ROOT/grupos"
VSFTPD_CONF="/etc/vsftpd.conf"

conf_ftp "$VSFTPD_CONF" "$FTP_ROOT"

echo "--- CONFIGURACIÓN SERVIDOR FTP - ANDREA CASTELLANOS ---"

    while true; do
        echo "1. Crear usuario"
        echo "2. Cambiar un usuario de grupo"
        echo "3. Salir"
        read -p "Elija la opción que desea realizar (1-3): " opc

        if [ "$opc" -eq 1 ]; then
            echo "Ingresa el nombre de usuario:"
            FTP_USER=$(solicitar_user)
            echo "Seleccione el grupo (1: Reprobados, 2: Recursadores):"
            FTP_GROUP=$(solicitar_grupo)
            crear_user "$FTP_USER" "$FTP_GROUP"
            echo "Configuración completa. Prueba acceder con un cliente FTP."
        elif [ "$opc" -eq 2 ]; then
            cambiar_user_grupo
        elif [ "$opc" -eq 3 ]; then
            echo "Saliendo..."
            exit 0
        else
            echo "Opción no válida. Intente de nuevo."
        fi
    done

