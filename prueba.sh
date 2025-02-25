#!/bin/bash

#Importar funciones de lectura
source "./funciones/bash/entrada/solicitar_ip.sh"
source "./funciones/bash/entrada/solicitar_rango.sh"
source "./funciones/bash/configuracion/fijar_ip.sh"
source "./funciones/bash/configuracion/conf_dhcp.sh"

#Usar la funcion leer ip y validarla
echo "Introduce la IP a fijar"
ip_fija=$(solicitar_ip)
echo "Ip válida: $ip_fija"

echo "Introduce la IP de inicio"
ip_inicio=$(solicitar_rango "$ip_fija")
echo "Introduce la IP de fin de subred"
ip_fin=$(solicitar_rango2 "$ip_inicio")

#Fijar ip
fijar_ip "$ip_fija"

conf_dhcp "$ip_fija" "$ip_inicio" "$ip_fin"




