#!/bin/bash
# funciones/bash/entrada/solicitar_grupo.sh

solicitar_grupo(){
    while true; do
        echo "Seleccione el grupo (1: Reprobados, 2: Recursadores):"
        read grupo

        if [[ "$grupo" == "1" ]]; then
            GROUP="reprobados"
            echo "$GROUP"
            return
        elif [[ "$grupo" == "2" ]]; then
            GROUP="recursadores"
            echo "$GROUP"
            return
        else
            echo "Error: Opción inválida. Por favor, ingrese 1 o 2." >&2  # Mensaje a stderr
        fi
    done
}
