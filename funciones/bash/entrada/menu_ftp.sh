#!/bin/bash
# funciones/bash/configuracion/menu_ftp.sh

menu_ftp() {
    while true; do
        echo "1. Crear usuario"
        echo "2. Cambiar un usuario de grupo"
        echo "3. Salir"
        read -p "Elija la opción que desea realizar (1-4): " opc

        if [ "$opc" -eq 1 ]; then
            echo "1"
        elif [ "$opc" -eq 2 ]; then
            echo "2"
        elif [ "$opc" -eq 3 ]; then
            echo "3"
        else
            echo "4"
        fi
    done
}

