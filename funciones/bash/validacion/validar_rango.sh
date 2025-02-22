#!/bin/bash
# funciones/bash/validacion/validar_rango.sh

validar_rango() {
    local ip1="$1"
    local ip2="$2"

    # Obtener los primeros tres octetos de cada IP
    IFS='.' read -r -a partesi <<< "$ip1"
    ip_i="${partesi[0]}.${partesi[1]}.${partesi[2]}"

    IFS='.' read -r -a partes <<< "$ip2"
    ip_a="${partes[0]}.${partes[1]}.${partes[2]}"

    # Comparar los primeros tres octetos
    if [[ "$ip_i" != "$ip_a" ]]; then
        return 1  # No están en el mismo rango
    fi

    return 0  # IPs en el mismo rango
}

validar_rango2(){
    local ip1="$1"
    local ip2="$2"

    # Dividir las IPs en partes usando '.' como delimitador
    IFS='.' read -r -a partesi <<< "$ip1"
    IFS='.' read -r -a partes <<< "$ip2"
    # Obtener los últimos octetos de las IPs
    ultimo_octeto_inicio=${partesi[3]}
    ultimo_octeto_fin=${partes[3]}

    # Validar que la IP de fin sea mayor que la de inicio
    if [[ "$ip1" == "$ip2" || "$ultimo_octeto_fin" -le "$ultimo_octeto_inicio" ]]; then
        return 1
    else
        return 0
    fi
}