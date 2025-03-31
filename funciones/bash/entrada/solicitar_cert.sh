#!/bin/bash
# funciones/bash/entrada/solicitar_cert.sh

solicitar_cert(){
    cert=0  # Marcar que no se ha solicitado un certificado
    while true; do

    read -p "Elija una opción (1-2): " op
    case "$op" in
        1)
            cert=1  # Marcar que se ha solicitado un certificado
            echo "$cert"
            break
            ;;
        2)
            echo "$cert"
            break
            ;;
        *)
            ;;
    esac
done
}