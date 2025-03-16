#!/bin/bash
# funciones/bash/configuracion/cambiar_user_grupo.sh

cambiar_user_grupo() {
    local FTP_USER NEW_GROUP

    while true; do
        # Pedir el nombre del usuario
        read -p "Ingrese el nombre del usuario que desea cambiar de grupo: " FTP_USER

        if [[ -z "$FTP_USER" ]]; then
            echo "Operación cancelada."
            return
        fi

        # Verificar si el usuario existe
        if ! id "$FTP_USER" &>/dev/null; then
            echo "Error: El usuario '$FTP_USER' no existe."
            return 1
        fi

        break  # Salir del bucle si el usuario es válido
    done

    while true; do
        # Pedir el nuevo grupo
        echo "Seleccione el nuevo grupo:"
        echo "1) Reprobados"
        echo "2) Recursadores"
        read -p "Opción: " opc

        if [[ -z "$opc" ]]; then
            echo "Operación cancelada."
            return
        fi

        case "$opc" in
            1)
                NEW_GROUP="reprobados"
                break
                ;;
            2)
                NEW_GROUP="recursadores"
                break
                ;;
            *)
                echo "Error: Opción inválida. Por favor, ingrese 1 o 2."
                ;;
        esac
    done
    
    GROUPS_DIR="/home/ftp/grupos"
    USER_DIR="/home/ftp/users/$FTP_USER"
    CURRENT_GROUP=$(ls "$USER_DIR" | grep -E "reprobados|recursadores")

    if [[ "$CURRENT_GROUP" == "$NEW_GROUP" ]]; then
        echo "El usuario ya pertenece al grupo "$NEW_GROUP"...."
        return
    fi

    if [[ -z "$CURRENT_GROUP" ]]; then
        echo "No se encontró un grupo asignado en la carpeta del usuario."
        exit 1
    fi

    echo "Cambiando de grupo $CURRENT_GROUP a $NEW_GROUP para $FTP_USER..."
    sudo gpasswd -d $FTP_USER $CURRENT_GROUP
    sudo usermod -aG $NEW_GROUP $FTP_USER
    sudo fuser -k "$USER_DIR/$CURRENT_GROUP"
    # Desmontar la carpeta actual
    sudo umount "$USER_DIR/$CURRENT_GROUP"

    # Renombrar la carpeta
    sudo mv "$USER_DIR/$CURRENT_GROUP" "$USER_DIR/$NEW_GROUP"

    # Montar la nueva carpeta del grupo
    sudo mount --bind "/home/ftp/grupos/$NEW_GROUP" "$USER_DIR/$NEW_GROUP"

    echo "Cambio de grupo completado para $FTP_USER."
}