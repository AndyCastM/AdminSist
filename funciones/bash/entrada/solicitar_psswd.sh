#!/bin/bash
# funciones/bash/entrada/solicitar_psswd.sh

solicitar_psswd(){
    local username="$1"
    while true; do
    echo "Ingrese la contraseña para $username:"
    read -s PASSWORD1
    echo "Confirme la contraseña:"
    read -s PASSWORD2

    if [[ "$PASSWORD1" == "$PASSWORD2" && -n "$PASSWORD1" ]]; then
        echo "$PASSWORD2"
        return
    else
        echo "Error: Las contraseñas no coinciden o están vacías. Intente de nuevo." >&2  # Mensaje a stderr
    fi
done
}