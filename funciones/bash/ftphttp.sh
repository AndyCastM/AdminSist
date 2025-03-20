#!/bin/bash

source "./entrada/solicitar_puerto.sh"
source "./configuracion/conf_http.sh"
source "./configuracion/conf_CERTHTTP.sh"
source "./menu/menu_cert.sh"

ftphttp() {
    local domain="10.0.0.17"
    local user="ftplinux"
    local pass="linux"

    while true; do
        echo "= CONFIGURACIÓN DE SERVICIOS HTTP DISPONIBLES ="

        # Listar carpetas en el servidor FTP y numerarlas
        # mapfile almacena la salida en el array folders
        # -t eliminamos saltos de línea
        mapfile -t folders < <(curl -s --user "$user:$pass" "ftp://$domain/" | awk '{print $NF}')
        
        #${#folders[@]} obtiene el tamaño del array 
        if [[ ${#folders[@]} -eq 0 ]]; then
            echo "No se encontraron servicios en el servidor FTP."
            return
        fi

        # Mostramos en pantalla las carpetas obtenidas
        # ${!folders[@]} obtiene los índices del array
        for i in "${!folders[@]}"; do
            echo "$((i + 1)). ${folders[i]}"
        done

        while true; do
            read -p "Elija una opción (1-${#folders[@]}), 0 para Salir: " op

            # Salir si elige 0
            if [[ "$op" -eq 0 ]]; then
                echo "Saliendo..."
                return
            fi

            # Verificar opción válida
            # -lt menor -gt mayor
            if [[ "$op" -lt 1 || "$op" -gt ${#folders[@]} ]]; then
                echo "Opción no válida. Intente de nuevo."
                continue
            else 
                break
            fi
        done

        # Seleccionamos la carpeta op-1 ya que originalmente la numeracion empieza en 0
        selected_folder="${folders[$((op - 1))]}"

        echo "Opción $op seleccionada: $selected_folder"
        echo "= Versiones disponibles en $selected_folder ="

        # Listar archivos dentro de la carpeta seleccionada
        mapfile -t files < <(curl -s --user "$user:$pass" "ftp://$domain/$selected_folder/" | awk '{print $NF}')
        
        if [[ ${#files[@]} -eq 0 ]]; then
            echo "No se encontraron archivos en la carpeta seleccionada."
            continue
        fi

        # Mostramos en pantalla los archivos obtenidos
        for i in "${!files[@]}"; do
            echo "$((i + 1)). ${files[i]}"
        done

        while true; do
            read -p "Elija un archivo para descargar (1-${#files[@]}), 0 para volver: " op2

            if [[ "$op2" -eq 0 ]]; then
                return
            fi

            # Verificar opción válida
            if [[ "$op2" -lt 1 || "$op2" -gt ${#files[@]} ]]; then
                echo "Opción no válida. Intente de nuevo."
                continue
            else
                break
            fi
        done
        # Seleccionamos el archivo op2-1 ya que originalmente la numeracion empieza en 0
        selected_file="${files[$((op2 - 1))]}"
        
        if [[ "$selected_folder" == "OpenLiteSpeed" ]]; then
            version="${selected_file%.tgz}"  # Remover .tgz y obtener el nombre completo
        else
            version=$(echo "$selected_file" | grep -oP '[0-9]+\.[0-9]+\.[0-9]+') # Obtenemos solamente el numero de la version 
        fi

        if [[ -z "$version" ]]; then
            echo "No se pudo extraer la versión del archivo."
            continue
        fi

        echo "Descargando $selected_file desde $selected_folder..."
        
        wget --user="$user" --password="$pass" "ftp://$domain/$selected_folder/$selected_file" -O "/tmp/$selected_file"

        echo "Descarga completada: /tmp/$selected_file"

        port=$(solicitar_puerto)
        if [[ -z "$port" ]]; then
            continue
        fi

        # Configurar el servicio según el nombre de la carpeta
        configurar_servicio "$selected_folder" "$port" "$version"
        
        # Preguntar si desea habilitar SSL
        menu_cert
        cert=$(solicitar_cert)
        if [ "$cert" -eq 1 ]; then
            configurar_ssl "$selected_folder" "$port"
        fi


    done
}

# Función para configurar el servicio según el tipo
configurar_servicio() {
    local servicio="$1"
    local port="$2"
    local archivo="$3"

    case "$servicio" in
        "Apache")
            conf_apache "$port" "$archivo" "1"
            ;;
        "Nginx")
            conf_nginx "$port" "$archivo" "1"
            ;;
        "OpenLiteSpeed")
            conf_litespeed "$port" "$archivo" "1"
            ;;
        *)
            echo "Servicio no reconocido: $servicio"
            ;;
    esac
}

#Función para configurar SSL según el servicio
configurar_ssl() {
    local servicio="$1"
    local port="$2"

    case "$servicio" in
        "Apache")
            cert_apache "$port"
            ;;
        "Nginx")
            cert_nginx "$port"
            ;;
        "OpenLiteSpeed")
            cert_ols "$port"
            ;;
        *)
            echo "No se ha configurado SSL para este servicio."
            ;;
    esac
}