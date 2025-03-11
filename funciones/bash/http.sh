#!/bin/bash

source "./menu/menu_http.sh"
source "./configuracion/obtener_version.sh"
source "./entrada/solicitar_ver.sh"
source "./entrada/solicitar_puerto.sh"

while true; do
    menu_http
    read -p "Elija el servicio HTTP que desea configurar (1-3): " op
            
    if [ "$op" -eq 1 ]; then
        versions=$(obtener_version "Apache")
        stable=$(echo "$versions" | head -1)
        menu_http2 "Apache" "$stable" " "
        echo "Elija la versión que desea instalar: "
        op2=$(solicitar_ver "Apache") 
        echo "Ingresa el puerto:"   
        port=$(solicitar_puerto)
    elif [ "$op" -eq 2 ]; then
        versions=$(obtener_version "Nginx")
        stable=$(echo "$versions" | tail -n 2 | head -1)
        mainline=$(echo "$versions" | tail -1)
        menu_http2 "Nginx" "$stable" "$mainline"
        echo "Elija la versión que desea instalar: "
        op2=$(solicitar_ver "Nginx")
        echo "Ingresa el puerto:"   
        port=$(solicitar_puerto)
    elif [ "$op" -eq 3 ]; then
        versions=$(obtener_version "OpenLiteSpeed")
        stable=$(echo "$versions" | tail -n 2 | head -1)
        mainline=$(echo "$versions" | tail -1)
        menu_http2 "OpenLiteSpeed" "$stable" "$mainline"
        echo "Elija la versión que desea instalar: "
        op2=$(solicitar_ver "OpenLiteSpeed")
        echo "Ingresa el puerto:"   
        port=$(solicitar_puerto)
    elif [ "$op" -eq 4 ]; then
        echo "Saliendo..."
        exit 0
    else
        echo "Opción no válida. Intente de nuevo."
    fi
done
