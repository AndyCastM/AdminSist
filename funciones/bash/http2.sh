#!/bin/bash

source "./menu/menu_http.sh"
source "./menu/menu_cert.sh"
source "./configuracion/conf_CERTHTTP.sh"
source "http.sh"

# Verificar si el script se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root"
    exit 1
fi

cert=0  # Variable para indicar si se generó un certificado

while true; do
    echo "= CONFIGURACIÓN DE SERVICIOS HTTP ="
    menu_cert

    read -p "Elija una opción (1-3): " op
    case "$op" in
        1)
            echo "Opción 1 seleccionada: Crear certificado SSL"
            cert=1  # Marcar que se ha solicitado un certificado
            break
            ;;
        2)
            break
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

while true; do
    menu_http3

    read -p "Elija una opción (1-3): " op2
    case "$op2" in
        1)
            http "$cert"
            ;;
        2)
            # Implementación futura de FTP
            echo "Opción 2 seleccionada: FTP (pendiente de implementación)"
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
