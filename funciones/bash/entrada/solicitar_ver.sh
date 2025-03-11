#!/bin/bash
# funciones/bash/entrada/solicitar_ver.sh

solicitar_ver() {
    local service="$1"
    local ver
    while true; do
        read ver
        if [ "$service" = "Apache" ] && [[ "$ver" =~ ^[1]$ ]]; then
            echo "$ver"  # Solo devuelve la opción válida
            return
        elif [ "$service" = "Nginx" ] && [[ "$ver" =~ ^[1-2]$ ]]; then
            echo "$ver"  # Solo devuelve la opción válida
            return
        elif [ "$service" = "OpenLiteSpeed" ] && [[ "$ver" =~ ^[1-2]$ ]]; then
            echo "$ver"  # Solo devuelve la opción válida
            return
        else
            echo "Opción no válida. Intenta de nuevo." >&2  # Mensaje a stderr
        fi
    done
}