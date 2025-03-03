#!/bin/bash

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root"
    exit 1
fi

read -p "Ingrese el nombre del usuario FTP: " FTP_USER
read -p "Ingrese el nuevo grupo (ej: reprobados, recursadores): " NEW_GROUP

GROUPS_DIR="/home/ftp/grupos"
USER_DIR="/home/ftp/users/$FTP_USER"
CURRENT_GROUP=$(ls "$USER_DIR" | grep -E "reprobados|recursadores")

if [[ -z "$CURRENT_GROUP" ]]; then
    echo "No se encontró un grupo asignado en la carpeta del usuario."
    exit 1
fi

echo "Cambiando de grupo $CURRENT_GROUP a $NEW_GROUP para $FTP_USER..."
sudo gpasswd -d $FTP_USER $CURRENT_GROUP
sudo usermod -aG $NEW_GROUP $FTP_USER
sudo fuser -k "$USER_DIR/$FTP_USER/$CURRENT_GROUP"
# Desmontar la carpeta actual
sudo umount "$USER_DIR/$CURRENT_GROUP"

# Renombrar la carpeta
sudo mv "$USER_DIR/$CURRENT_GROUP" "$USER_DIR/$NEW_GROUP"

# Montar la nueva carpeta del grupo
sudo mount --bind "/home/ftp/grupos/$NEW_GROUP" "$USER_DIR/$NEW_GROUP"

# Actualizar /etc/fstab para el montaje persistente
# sudo sed -i "\|$GROUPS_DIR/$CURRENT_GROUP $USERS_DIR/$FTP_USER/$CURRENT_GROUPR|d" /etc/fstab
# echo "/home/ftp/grupos/$NEW_GROUP $USER_DIR/$NEW_GROUP none bind 0 0" | sudo tee -a /etc/fstab

echo "Cambio de grupo completado para $FTP_USER."
