
#!/bin/bash
# funciones/bash/configuracion/conf_ftp.sh

conf_ftp_concert(){
    local VSFTPD_CONF="$1"
    local FTP_ROOT="$2"

    #Verificar si ya está instalado
    if systemctl list-unit-files | grep -q "vsftpd"; then
        echo "vsftpd ya está instalado."
    else
        echo "Instalando vsftpd..."
        sudo apt update && sudo apt install -y vsftpd 
        sudo groupadd reprobados
        sudo groupadd recursadores
        sudo groupadd ftpusers   

        # Generar certificado SSL autogitmado
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

        sudo sed -i 's/^anonymous_enable=.*/anonymous_enable=YES/' /etc/vsftpd.conf
        sudo sed -i 's/^#\(local_enable=YES\)/\1/' /etc/vsftpd.conf
        sudo sed -i 's/^#\(write_enable=YES\)/\1/' /etc/vsftpd.conf
        sudo sed -i 's/^#\(chroot_local_user=YES\)/\1/' /etc/vsftpd.conf
        sudo tee -a $VSFTPD_CONF > /dev/null <<EOF
        allow_writeable_chroot=YES
        anon_root=$FTP_ROOT/anon
EOF

        # Crear estructura de carpetas
        echo "Creando estructura de directorios..."
        sudo mkdir -p "$PUBLIC_DIR" "$USERS_DIR" "$GROUPS_DIR"
        sudo mkdir -p "$GROUPS_DIR/reprobados"
        sudo mkdir -p "$GROUPS_DIR/recursadores"
        sudo mkdir -p "$FTP_ROOT/anon/publica"

        # Asignar permisos a grupos
        echo "Configurando permisos..."
        sudo chmod 770 "$GROUPS_DIR/reprobados"
        sudo chmod 770 "$GROUPS_DIR/recursadores"
        sudo chown root:reprobados "$GROUPS_DIR/reprobados"
        sudo chown root:recursadores "$GROUPS_DIR/recursadores"

        # Permisos generales
        sudo chmod 755 /home/ftp
        sudo chmod 775 "$PUBLIC_DIR"
        sudo chown root:ftpusers "$PUBLIC_DIR"

        # Asegurar configuración del sistema
        echo "Configurando seguridad..."
        sudo chmod 755 /home/ftp

        # Abrir puertos en firewall
        echo "Configurando firewall..."
        sudo ufw allow 21/tcp

    fi

}
