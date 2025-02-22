#!/bin/bash
# funciones/bash/entrada/solicitar_dominio.sh

source "./funciones/bash/validacion/validar_dominio.sh"

solicitar_dom(){
    local dominio
    while true; do
        read dominio
        if validar_dominio "$dominio"; then
            echo "$dominio"  # Solo devuelve el dominio válido
            return
        else
            echo "Dominio no válido. Intenta de nuevo." >&2  # Mensaje a stderr
        fi
    done
}
