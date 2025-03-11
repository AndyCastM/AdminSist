#!/bin/bash
# funciones/bash/configuracion/conf_http.sh

source "./variables/variables_http.sh"

conf_litespeed(){
    local port="$1"
    local version="$2"
    echo "Descargando $version..."

    # Variable URL para descargar la version
    url="https://openlitespeed.org/packages/"$version".tgz"

    wget -O litespeed.tgz "$url"
    #Extraer archivos
    tar -xzf litespeed.tgz > /dev/null 2>&1
    #Cambiar de directorio e instalar
    cd openlitespeed

    #Instalar dependencias necesarias
    sudo apt update -y > /dev/null 2>&1
    sudo apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev > /dev/null 2>&1

    #Instalar openlitespeed
    sudo bash install.sh > /dev/null 2>&1

    # Modificar el puerto de escucha
    config="/usr/local/lsws/conf/httpd_config.conf"
    sudo sed -i "s/\(listener Default\)/\1\n  address *:$port/" "$config"

    # Iniciar el servicio
    sudo /usr/local/lsws/bin/lswsctrl start
}

conf_apache(){
    local port="$1"
    local version="$2"
    echo "Descargando Apache $version..."

    #Descargar e instalar la versión seleccionada
    cd /tmp
    wget https://downloads.apache.org/httpd/httpd-$version.tar.gz
    tar -xzvf httpd-$version.tar.gz > /dev/null 2>&1
    cd httpd-$version

    #Instalar dependencias necesarias
    sudo apt update -y > /dev/null 2>&1
    sudo apt-get install -y libapr1 libapr1-dev > /dev/null 2>&1
    sudo apt-get install -y libaprutil1 libaprutil1-dev > /dev/null 2>&1
    sudo apt install -y build-essential wget libpcre3 libpcre3-dev libssl-dev > /dev/null 2>&1

    #Configurar Apache para la instalación
    ./configure --prefix=/usr/local/apache2 --enable-so --enable-mods-shared=all --enable-ssl > /dev/null 2>&1
    #Compilar e instalar Apache
    make > /dev/null 2>&1
    sudo make install > /dev/null 2>&1

    #Configurar el puerto
    sudo sed -i "s/Listen 80/Listen $port/" /usr/local/apache2/conf/httpd.conf 

    #Asegurarse de que la directiva 'ServerName' esté configurada
    echo "ServerName localhost" | sudo tee -a /usr/local/apache2/conf/httpd.conf 
            
    #Reiniciar Apache
    sudo /usr/local/apache2/bin/apachectl start 
    sudo ufw allow $port/tcp
}

conf_nginx(){
    
}
