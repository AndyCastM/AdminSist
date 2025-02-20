#!/bin/bash

#Importar funciones de lectura
source "./funciones/bash/entrada/leer_ip.sh"

#Usar la funcion leer ip y validarla
echo "Introduce la dirección IP válida"
ip_valida=$(leer_ip)

echo "$ip_valida"