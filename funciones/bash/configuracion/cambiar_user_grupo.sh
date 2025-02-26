#!/bin/bash
# funciones/bash/configuracion/cambiar_user_grupo.sh

cambiar_user_grupo() {
    local USUARIO GRUPO_NUEVO

    # Pedir el nombre del usuario
    echo "Ingrese el nombre del usuario que desea cambiar de grupo:"
    read USUARIO

    # Verificar si el usuario existe
    if ! id "$USUARIO" &>/dev/null; then
        echo "Error: El usuario '$USUARIO' no existe."
        return 1
    fi

    # Pedir el nuevo grupo
    echo "Seleccione el nuevo grupo:"
    echo "1) Reprobados"
    echo "2) Recursadores"
    read opc

    case $opc in
        1)
            GRUPO_NUEVO="reprobados"
            ;;
        2)
            GRUPO_NUEVO="recursadores"
            ;;
        *)
            echo "Error: Opción inválida."
            return 1
            ;;
    esac

    # Cambiar el grupo del usuario
    sudo usermod -g "$GRUPO_NUEVO" "$USUARIO"

    # Asignar la nueva carpeta de grupo
    sudo mkdir -p /home/$USUARIO/grupo
    sudo chown $USUARIO:$GRUPO_NUEVO /home/$USUARIO/grupo
    sudo chmod 770 /home/$USUARIO/grupo

    # Montar la nueva carpeta de grupo y actualizar fstab
    sudo umount /home/$USUARIO/grupo 2>/dev/null  # Desmontar si ya existía
    sudo mount --bind /home/$GRUPO_NUEVO /home/$USUARIO/grupo
    sudo sed -i "\|/home/$USUARIO/grupo|d" /etc/fstab  # Eliminar la línea anterior si existía
    echo "/home/$GRUPO_NUEVO /home/$USUARIO/grupo none bind 0 0" | sudo tee -a /etc/fstab

    echo "El usuario '$USUARIO' ahora pertenece al grupo '$GRUPO_NUEVO'."
}