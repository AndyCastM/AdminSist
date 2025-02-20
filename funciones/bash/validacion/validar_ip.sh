#!/bin/bash
# funciones/bash/validacion/validar_ip.sh

validar_ip() {
    local ip="$1"
    local regex="^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))$"

    if [[ $ip =~ $regex ]]; then
        IFS='.' read -r -a partes <<< "$ip"
        if [[ "${partes[3]}" == "1" || "${partes[3]}" == "255" ]]; then
            return 1  # IP no válida
        fi
        return 0  # IP válida
    fi
    return 1  # IP no válida
}
