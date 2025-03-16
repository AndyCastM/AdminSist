#!/bin/bash
# funciones/bash/configuracion/conf_ftp.sh

conf_ftp(){
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

        sudo sed -i 's/^anonymous_enable=.*/anonymous_enable=YES/' /etc/vsftpd.conf
        sudo sed -i 's/^#\(local_enable=YES\)/\1/' /etc/vsftpd.conf
        sudo sed -i 's/^#\(write_enable=YES\)/\1/' /etc/vsftpd.conf
        sudo sed -i 's/^#\(chroot_local_user=YES\)/\1/' /etc/vsftpd.conf
        sudo tee -a $VSFTPD_CONF > /dev/null <<EOF
        allow_writeable_chroot=YES
        anon_root=$FTP_ROOT/anon
        anon_umask=022
        local_umask=002
        ftpd_banner=Welcome to Andrea's FTP server
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
        sudo chmod 2775 "$PUBLIC_DIR"
        sudo chown root:ftpusers "$PUBLIC_DIR"

        # Asegurar configuración del sistema
        echo "Configurando seguridad..."
        sudo chmod 755 /home/ftp

        # Abrir puertos en firewall
        echo "Configurando firewall..."
        sudo ufw allow 21/tcp

    fi

}

