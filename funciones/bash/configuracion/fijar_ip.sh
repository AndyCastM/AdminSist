#!/bin/bash
# funciones/bash/configuracion/fijar_ip.sh

fijar_ip(){
    local ip="$1"

    echo "network:
    version: 2
    renderer: networkd
    ethernets:
        enp0s3:
        dhcp4: true
        enp0s8:
        addresses: [$ip/24]
        nameservers:
            addresses: [8.8.8.8, 1.1.1.1]" | sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null

    echo "Fijando la IP $ip en netplan"
    
    
    echo "Fijando la IP $ip en netplan"
    #Aplicar cambios
    sudo netplan apply
    echo "Aplicando cambios en netplan"
}