#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root" 
    exit 1
fi

source "./dockerconfig.sh"

echo "--- Bienvenido a la configuración de Docker ---"
echo "Instalando Docker..."
instalar_docker

while true; do
    echo "Seleccione la opción que desea configurar:"
    echo "1) Montar Apache"
    echo "2) Personalizar imagen de Apache"
    echo "3) Clonar la imagen de Apache"
    echo "4) Crear conexión entre contenedores"
    echo "5) Verificar contenedores"
    echo "6) Salir"
    read -p "Elija una opción (1-5): " op2
    case "$op2" in
        1)
            echo "Opción 1 seleccionada: Montar Apache"
            echo "Montando Apache..."
            montar_apache
            ;;
        2)
            echo "Opción 2 seleccionada: Personalizar imagen de Apache"
            echo "Modificando Apache..."
            modificar_apache
            ;;
        3)
            echo "Opción 3 seleccionada: Clonar la imagen de Apache"
            crear_dockerfile
            ;;
        4)
            echo "Opción 4 seleccionada: Crear conexión entre contenedores"
            echo "Creando conexión entre contenedores..."
            contenedores_postgres
            ;;
        5)
            echo "Opción 5 seleccionada: Verificar contenedores"
            comunicacion_contenedores
            ;;
        6)
            echo "Opción 5 seleccionada: Salir"
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida. Intente de nuevo."
            ;;
    esac
done

