#!/bin/bash
# funciones/bash/entrada/solicitar_puerto.sh

solicitar_puerto(){
    local port

    while true; do
        read port
        if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1024 ] || [ "$port" -gt 65535 ]; then
            echo "Puerto no válido. Intenta de nuevo" >&2  
        else 
            echo "$port"
            return
        fi
    done
}