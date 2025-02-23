#!/bin/bash
# funciones/bash/entrada/solicitar_rango.sh

source "./funciones/bash/validacion/validar_rango.sh"

solicitar_rango(){
    local ip_fija="$1"
    while true; do
        ip_inicio=$(solicitar_ip)

        if validar_rango "$ip_fija" "$ip_inicio"; then
            echo "$ip_inicio"
            return  # Sale del bucle correctamente
        else
            echo "Las IPs no están en el mismo rango. Intenta de nuevo." >&2
        fi
    done
}


solicitar_rango2(){
    local ip_inicio="$1"
    while true; do
        ip_fin=$(solicitar_ip)

        # Ejecutar las funciones y obtener sus códigos de salida
        validar_rango "$ip_fin" "$ip_inicio"
        resultado1=$?  # Capturar el código de salida de la primera función

        validar_rango2 "$ip_inicio" "$ip_fin"  #Aqui se debe de pasar primero la ip de inicio para hacer bien la validacion
        resultado2=$?  # Capturar el código de salida de la segunda función

        # Evaluar los resultados de ambas funciones
        if [[ $resultado1 -eq 0 && $resultado2 -eq 0 ]]; then
            echo "$ip_fin"
            return  # Sale del bucle correctamente
        else
            echo "Las IPs no están en el mismo rango o no cumplen los criterios. Intenta de nuevo." >&2
        fi
    done
}