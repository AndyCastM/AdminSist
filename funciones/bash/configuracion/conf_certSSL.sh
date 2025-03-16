#!/bin/bash
# funciones/bash/configuracion/conf_certSSL.sh

conf_certSSL(){
    # Generar certificado SSL autofirmado
    # Verificar si el certificado ya existe
    if [ ! -f "/etc/ssl/private/vsftpd.pem" ]; then
        # Generar certificado SSL solo si no existe
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/ssl/private/vsftpd.pem \
            -out /etc/ssl/private/vsftpd.pem \
            -subj "/C=MX/ST=Sinaloa/L=LosMochis/O=MyCompany/OU=IT/CN=myftpserver"
    fi

    # Configuramos VFTPD para agregarle el certificado SSL
    sudo sed -i 's/ssl_enable=NO/ssl_enable=YES/g' /etc/vsftpd.conf

    # Configuramos VFTPD solo si las líneas no existen en el archivo
    if ! grep -q "allow_anon_ssl=YES" /etc/vsftpd.conf; then
        echo "allow_anon_ssl=YES" | sudo tee -a /etc/vsftpd.conf
    fi

    if ! grep -q "force_local_data_ssl=YES" /etc/vsftpd.conf; then
        echo "force_local_data_ssl=YES" | sudo tee -a /etc/vsftpd.conf
    fi

    if ! grep -q "force_local_logins_ssl=YES" /etc/vsftpd.conf; then
        echo "force_local_logins_ssl=YES" | sudo tee -a /etc/vsftpd.conf
    fi

    if ! grep -q "ssl_tlsv1=YES" /etc/vsftpd.conf; then
        echo "ssl_tlsv1=YES" | sudo tee -a /etc/vsftpd.conf
    fi

    if ! grep -q "ssl_sslv2=NO" /etc/vsftpd.conf; then
        echo "ssl_sslv2=NO" | sudo tee -a /etc/vsftpd.conf
    fi

    if ! grep -q "ssl_sslv3=NO" /etc/vsftpd.conf; then
        echo "ssl_sslv3=NO" | sudo tee -a /etc/vsftpd.conf
    fi

    sudo sed -i "s|rsa_cert_file=.*|rsa_cert_file=/etc/ssl/private/vsftpd.pem|g" /etc/vsftpd.conf
    sudo sed -i "s|rsa_private_key_file=.*|rsa_private_key_file=/etc/ssl/private/vsftpd.pem|g" /etc/vsftpd.conf

    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd
}