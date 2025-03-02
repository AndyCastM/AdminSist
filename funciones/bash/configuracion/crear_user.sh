#!/bin/bash
# funciones/bash/configuracion/crear_user.sh

crear_user(){
    # Variables principales
    FTP_ROOT="/home/ftp"
    PUBLIC_DIR="$FTP_ROOT/publica"
    USERS_DIR="$FTP_ROOT/users"
    GROUPS_DIR="$FTP_ROOT/grupos"
    VSFTPD_CONF="/etc/vsftpd.conf"

    local FTP_USER="$1"
    local FTP_GROUP="$2"
    
    # Crear usuario FTP
    echo "Creando usuario $FTP_USER..."
    sudo useradd -m -d "$USERS_DIR/$FTP_USER" -s /usr/sbin/nologin "$FTP_USER"
    sudo passwd "$FTP_USER"
    sudo usermod -aG "$FTP_GROUP" "$FTP_USER"
    sudo usermod -aG "ftpusers" "$FTP_USER"

    # Crear carpetas del usuario
    echo "Configurando carpetas para $FTP_USER..."
    sudo mkdir -p "$USERS_DIR/$FTP_USER/publica"
    sudo mkdir -p "$USERS_DIR/$FTP_USER/$FTP_GROUP"

    # Enlazar carpetas con mount --bind
    sudo mkdir -p "$USERS_DIR/$FTP_USER/$FTP_USER"
    sudo chmod 700 "$USERS_DIR/$FTP_USER/$FTP_USER"
    sudo chown -R "$FTP_USER:$FTP_USER" "$USERS_DIR/$FTP_USER/"
    sudo mount --bind "$GROUPS_DIR/$FTP_GROUP" "$USERS_DIR/$FTP_USER/$FTP_GROUP"
    sudo mount --bind "$PUBLIC_DIR" "$USERS_DIR/$FTP_USER/publica"
    sudo mount --bind "$PUBLIC_DIR" "$FTP_ROOT/anon/publica"

    sudo chmod 750 "$USERS_DIR/$FTP_USER"
    sudo chown -R "$FTP_USER:ftpusers" "$USERS_DIR/$FTP_USER"

    # Configuración individual del usuario
    echo "Configurando acceso para $FTP_USER..."
    sudo passwd -u "$FTP_USER"
    sudo usermod -s /bin/bash "$FTP_USER"

    # Reiniciar servicio vsftpd
    echo "Reiniciando servicio FTP..."
    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd

}