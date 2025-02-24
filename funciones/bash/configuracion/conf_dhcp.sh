#!/bin/bash
# funciones/bash/configuracion/conf_dhcp.sh

conf_dhcp(){
    local ip="$1"
    local inicio="$2"
    local fin="$3"

    sudo apt update
    sudo apt-get install isc-dhcp-server -y

    sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="enp0s8"/g' /etc/default/isc-dhcp-server

    #Configurar el archivo dhcpd.conf
    sudo tee -a /etc/dhcp/dhcpd.conf > /dev/null <<EOF
    group red-interna {
        subnet $(echo $ip | awk -F. '{print $1"."$2"."$3}').0 netmask 255.255.255.0 {
            range $inicio $fin;
            option routers $(echo $ip | awk -F. '{print $1"."$2"."$3}').1;
            option domain-name-servers 8.8.8.8;
            option domain-name "DHCP Server d Andrea";
            default-lease-time 1800;   
            max-lease-time 3600;       
        }
    }
EOF

    sudo service isc-dhcp-server restart
    sudo service isc-dhcp-server status
}