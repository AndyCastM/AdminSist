#!/bin/bash
# funciones/bash/entrada/leer_ip.sh
source "./funciones/bash/validacion/validar_ip.sh"

leer_ip() {
    local ip
    while true; do
        read ip
        if validar_ip "$ip"; then
            echo "IP válida: $ip"
            return
        else
            echo "IP inválida. Intenta de nuevo."
            return 1
        fi
    done
}
