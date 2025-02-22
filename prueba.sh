#!/bin/bash

#Importar funciones de lectura
source "./funciones/bash/entrada/solicitar_ip.sh"
source "./funciones/bash/validacion/validar_rango.sh"
source "./funciones/bash/configuracion/conf_dhcp.sh"

#Usar la funcion leer ip y validarla
echo "Introduce la IP a fijar"
ip_fija=$(solicitar_ip)
echo "Ip válida: $ip_fija"

while true; do
    echo "Introduce la IP de inicio"
    ip_inicio=$(solicitar_ip)

    if validar_rango "$ip_fija" "$ip_inicio"; then
        echo "IP de inicio válida y en el mismo rango."
        break  # Sale del bucle correctamente
    else
        echo "Las IPs no están en el mismo rango. Intenta de nuevo."
    fi
done

while true; do
    echo "Introduce la IP de fin de subred"
    ip_fin=$(solicitar_ip)

    # Ejecutar las funciones y obtener sus códigos de salida
    validar_rango "$ip_fin" "$ip_inicio"
    resultado1=$?  # Capturar el código de salida de la primera función

    validar_rango2 "$ip_inicio" "$ip_fin"  #Aqui se debe de pasar primero la ip de inicio para hacer bien la validacion
    resultado2=$?  # Capturar el código de salida de la segunda función

    # Evaluar los resultados de ambas funciones
    if [[ $resultado1 -eq 0 && $resultado2 -eq 0 ]]; then
        echo "IP de fin válida y en el mismo rango."
        break  # Sale del bucle correctamente
    else
        echo "Las IPs no están en el mismo rango o no cumplen los criterios. Intenta de nuevo."
    fi
done

conf_dhcp "$ip_fija" "$ip_inicio" "$ip_fin"




