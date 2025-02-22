#!/bin/bash
# funciones/bash/validacion/validar_dominio.sh

validar_dominio () {
    local dominio="$1"
    local regex="^([a-zA-Z0-9-]{4,}\.)+(com|net|edu|blog|mx|tech|site)$"

    if [[ $dominio =~ $regex ]]; then
        return 0  #True
    else
        return 1  #False
    fi
}
