#!/bin/bash
# funciones/bash/configuracion/conf_dns.sh

conf_ftp(){

    # Verificar que se ejecute como root
    if [[ $EUID -ne 0 ]]; then
        echo "Este script debe ejecutarse como root" 
        exit 1
    fi

    sudo apt-get update
    sudo apt install vsftpd -y

    sudo sed -i 's/^#\(anonymous_enable=YES\)/\1/' /etc/vsftpd.conf
    sudo sed -i 's/^#\(local_enable=YES\)/\1/' /etc/vsftpd.conf
    sudo sed -i 's/^#\(write_enable=YES\)/\1/' /etc/vsftpd.conf
    sudo sed -i 's/^#\(chroot_local_user=YES\)/\1/' /etc/vsftpd.conf
    sudo sed -i 's/^#\(allow_writeable_chroot=YES\)/\1/' /etc/vsftpd.conf

    sudo groupadd reprobados
    sudo groupadd recursadores

    sudo mkdir -p /publica
    sudo chmod 755 /publica
    sudo chown nobody:nogroup /publica
}