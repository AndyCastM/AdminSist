#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root" 
    exit 1
fi

source "./dockerconfig.sh"

echo "--- Bienvenido a la configuración de Docker ---"

while true; do
    echo "Seleccione la opción que desea configurar:"
    echo "1) Instalar Docker"
    echo "2) Montar Apache"
    echo "3) Personalizar imagen de Apache"
    echo "4) Clonar la imagen de Apache"
    echo "5) Crear conexión entre contenedores"
    echo "6) Verificar contenedor desde alumno hacia profesor"
    echo "7) Verificar contenedor desde profesor hacia alumno"
    echo "8) Salir"
    read -p "Elija una opción (1-8): " op2
    case "$op2" in
        1)
            echo "Opción 1 seleccionada: Instalar Docker"
            echo "Instalando Docker..."
            instalar_docker
            ;;
        2)
            echo "Opción 2 seleccionada: Montar Apache"
            echo "Montando Apache..."
            montar_apache
            ;;
        3)
            echo "Opción 3 seleccionada: Personalizar imagen de Apache"
            echo "Modificando Apache..."
            modificar_apache
            ;;
        4)
            echo "Opción 4 seleccionada: Clonar la imagen de Apache"
            crear_dockerfile
            ;;
        5)
            echo "Opción 5 seleccionada: Crear conexión entre contenedores"
            echo "Creando conexión entre contenedores..."
            contenedores_postgres
            ;;
        6)
            echo "Opción 6 seleccionada: Verificar contenedor desde alumno hacia profesor"
            echo "Verificando contenedor desde alumno hacia profesor..."
            comunicacion_contenedores
            ;;
        7)
            echo "Opción 7 seleccionada: Verificar contenedor desde profesor hacia alumno"
            echo "Verificando contenedor desde profesor hacia alumno..."
            comunicacion_contenedores2
            ;;
        8)
            echo "Opción 7 seleccionada: Salir"
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida. Intente de nuevo."
            ;;
    esac
done

