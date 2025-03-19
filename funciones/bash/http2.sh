#!/bin/bash

source "./menu/menu_http.sh"
source "./menu/menu_cert.sh"
source "./configuracion/conf_CERTHTTP.sh"
source "http.sh"
source "ftphttp.sh"

# Verificar si el script se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root"
    exit 1
fi


while true; do
    menu_http3

    read -p "Elija una opción (1-2): " op2
    case "$op2" in
        1)
            echo "Opción 1 seleccionada: Web"
            http
            ;;
        2)
            # Implementación futura de FTP
            echo "Opción 2 seleccionada: FTP"
            ftphttp
            ;;
        3)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida. Intente de nuevo."
            ;;
    esac
done
