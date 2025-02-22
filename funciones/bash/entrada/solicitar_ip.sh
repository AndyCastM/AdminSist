#!/bin/bash
# funciones/bash/entrada/solicitar_ip.sh

source "./funciones/bash/validacion/validar_ip.sh"

solicitar_ip() {
    local ip
    while true; do
        read ip
        if validar_ip "$ip"; then
            echo "$ip"  # Solo devuelve la IP válida
            return
        else
            echo "IP inválida. Intenta de nuevo." >&2  # Mensaje a stderr
        fi
    done
}
