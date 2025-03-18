#!/bin/bash

source "./entrada/solicitar_puerto.sh"
source "./configuracion/conf_http.sh"
source "./configuracion/conf_CERTHTTP.sh"
source "./menu/menu_cert.sh"

ftphttp(){
    local domain="10.0.0.17"

    while true; do
        echo "= CONFIGURACIÓN DE SERVICIOS HTTP DISPONIBLES ="
        #Listar carpetas (Servicios Http)
        curl -s --user ftplinux:linux ftp://$domain| awk '{print $NF}' | nl
        read -p "Elija una opción (1-3), 4 para Salir: " op
        case "$op" in
            1)
                echo "Opción 1 seleccionada: Apache"
                #Listar contenido de Apache
                curl -s --user ftplinux:linux ftp://$domain/Apache/ | awk '{print $NF}' | nl
                read -p "¿Desea instalar Apache? 1 -Si, 2-No: " op2
                [[ -z "$op2" ]] && return
                case "$op2" in
                    1)
                        port=$(solicitar_puerto)
                        if [[ -z "$port" ]]; then
                            continue
                        fi
                        echo "Instalando Apache..."
                        #Descargar Apache
                        wget --user=ftplinux --password=linux ftp://$domain/Apache/httpd-2.4.63.tar.gz -O /tmp/httpd-2.4.63.tar.gz
                        stable="2.4.63"
                        conf_apache "$port" "$stable" "1"
                        menu_cert
                        cert=$(solicitar_cert)
                        if [ "$cert" -eq 1 ]; then
                            cert_apache "$port"
                        else
                            continue
                        fi
                        ;;
                    2)
                        echo "Regresando..."
                        continue
                        ;;
                    *)
                        echo "Opción no válida. Intente de nuevo."
                        ;;
                esac
                break
                ;;
            2)
                echo "Opción 2 seleccionada: Nginx"
                #Listar contenido de Nginx
                curl -s --user ftplinux:linux ftp://$domain/Nginx/ | awk '{print $NF}' | nl
                read -p "Elija una versión de Nginx (1-2): " op2
                [[ -z "$op2" ]] && return

                case "$op2" in
                    1)
                        port=$(solicitar_puerto)
                        if [[ -z "$port" ]]; then
                            continue
                        fi
                        echo "Descargando Nginx 1.26.3..."
                        #Descargar Nginx 1.26.3
                        wget --user=ftplinux --password=linux ftp://$domain/Nginx/nginx-1.26.3.tar.gz -O /tmp/nginx-1.26.3.tar.gz
                        stable="1.26.3"
                        conf_nginx "$port" "$stable" "1"
                        ;;
                    2)
                        port=$(solicitar_puerto)
                        if [[ -z "$port" ]]; then
                            continue
                        fi
                        echo "Descargando Nginx 1.27.4..."
                        #Descargar Nginx 1.27.4
                        wget --user=ftplinux --password=linux ftp://$domain/Nginx/nginx-1.27.4.tar.gz -O /tmp/nginx-1.27.4.tar.gz
                        mainline="1.27.4"
                        conf_nginx "$port" "$mainline" "1"
                        ;;
                    *)
                        echo "Opción no válida. Intente de nuevo."
                        ;;
                esac
                menu_cert
                cert=$(solicitar_cert)
                if [ "$cert" -eq 1 ]; then
                    cert_nginx "$port"
                else
                    continue
                fi
                break
                ;;
            3)
                echo "Opción 3 seleccionada: OpenLiteSpeed"
                #Listar contenido de OpenLiteSpeed
                curl -s --user ftplinux:linux ftp://$domain/OpenLiteSpeed/ | awk '{print $NF}' | nl
                read -p "Elija una versión de OpenLiteSpeed (1-2): " op2
                [[ -z "$op2" ]] && return

                case "$op2" in
                    1)
                        port=$(solicitar_puerto)
                        if [[ -z "$port" ]]; then
                            continue
                        fi
                        echo "Descargando OpenLiteSpeed 1.7.19..."
                        #Descargar OpenLiteSpeed 1.7.19
                        wget --user=ftplinux --password=linux ftp://$domain/OpenLiteSpeed/openlitespeed-1.7.19.tgz -O /tmp/openlitespeed-1.7.19.tgz
                        stable="openlitespeed-1.7.19"
                        conf_litespeed "$port" "$stable" "1"
                        ;;
                    2)
                        port=$(solicitar_puerto)
                        if [[ -z "$port" ]]; then
                            continue
                        fi
                        echo "Descargando OpenLiteSpeed 1.8.3..."
                        #Descargar OpenLiteSpeed 1.8.3
                        wget --user=ftplinux --password=linux ftp://$domain/OpenLiteSpeed/openlitespeed-1.8.3.tgz -O /tmp/openlitespeed-1.8.3.tgz
                        mainline="openlitespeed-1.8.3"
                        conf_litespeed "$port" "$mainline" "1"
                        ;;
                    *)
                        echo "Opción no válida. Intente de nuevo."
                        ;;
                esac
                menu_cert
                cert=$(solicitar_cert)
                if [ "$cert" -eq 1 ]; then
                    cert_ols "$port"
                else
                    continue
                fi
                break
                ;;
            4)
                echo "Saliendo..."
                return
                ;;
            *)
                echo "Opción no válida. Intente de nuevo."
                ;;
        esac

        # #Descargar Nginx
        # wget --user=ftplinux --password=linux ftp://$domain/Nginx/nginx-1.27.4.tar.gz -O /tmp/nginx-1.27.4.tar.gz
        # wget --user=ftplinux --password=linux ftp://$domain/Nginx/nginx-1.26.3.tar.gz -O /tmp/nginx-1.26.3.tar.gz
        # #Descargar OpenLiteSpeed
        # wget --user=ftplinux --password=linux ftp://$domain/OpenLiteSpeed/openlitespeed-1.7.19.tgz -O /tmp/openlitespeed-1.7.19.tgz
        # wget --user=ftplinux --password=linux ftp://$domain/OpenLiteSpeed/openlitespeed-1.8.3.tgz -O /tmp/openlitespeed-1.8.3.tgz

    done


}