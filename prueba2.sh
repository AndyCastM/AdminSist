#!/bin/bash

#Importar funciones de lectura
source "./funciones/bash/entrada/solicitar_ip.sh"
source "./funciones/bash/entrada/solicitar_dom.sh"
source "./funciones/bash/configuracion/fijar_ip.sh"
source "./funciones/bash/configuracion/conf_dns.sh"

#Pedir dominio
echo "Introduce el dominio"
dominio=$(solicitar_dom)
echo "Dominio válido: $dominio"

#Usar la funcion leer ip y validarla
echo "Introduce la IP a fijar"
ip_fija=$(solicitar_ip)
echo "Ip válida: $ip_fija"

#Fijar ip
fijar_ip "$ip_fija"

#Configurar servidor DNS
conf_dns "$ip_fija" "$dominio"