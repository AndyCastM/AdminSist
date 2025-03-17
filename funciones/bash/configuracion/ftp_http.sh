#!/bin/bash
# funciones/bash/configuracion/ftp_http.sh

source "./variables/variables_ftp.sh"

ftp_http(){

    # Verificar si ya está instalado
    if systemctl list-unit-files | grep -q "vsftpd"; then
        echo "vsftpd ya está instalado."
    else
        echo "Instalando vsftpd..."
        sudo apt update && sudo apt install -y vsftpd 

        # Configurar vsftpd.conf
        sudo sed -i 's/^#\(local_enable=YES\)/\1/' $VSFTPD_CONF
        sudo sed -i 's/^#\(write_enable=YES\)/\1/' $VSFTPD_CONF
        sudo sed -i 's/^#\(chroot_local_user=YES\)/\1/' $VSFTPD_CONF

        echo "allow_writeable_chroot=YES" | sudo tee -a $VSFTPD_CONF
        echo "ftpd_banner=Servicios HTTP" | sudo tee -a $VSFTPD_CONF

        # Crear estructura de carpetas
        echo "Creando estructura de directorios..."
        sudo mkdir -p "/srv/ftp/Windows/Apache"
        sudo mkdir -p "/srv/ftp/Windows/Nginx"
        sudo mkdir -p "/srv/ftp/Windows/IIS"
        sudo mkdir -p "/srv/ftp/Linux/Apache"
        sudo mkdir -p "/srv/ftp/Linux/Nginx"
        sudo mkdir -p "/srv/ftp/Linux/OpenLiteSpeed"

        # Asignar permisos
        echo "Configurando permisos..."
        sudo chmod -R 755 "/srv/ftp"

        # Crear usuarios
        echo "Creando usuarios FTP..."
        sudo adduser --disabled-password --gecos "" ftpwindows
        sudo adduser --disabled-password --gecos "" ftplinux

        echo "Estableciendo contraseñas para los usuarios..."
        echo "ftpwindows:windows" | sudo chpasswd
        echo "ftplinux:linux" | sudo chpasswd

        # Asignar directorios a usuarios
        sudo usermod -d /srv/ftp/Windows ftpwindows
        sudo usermod -d /srv/ftp/Linux ftplinux

        # Cambiar propietarios
        sudo chown -R ftpwindows:ftpwindows "/srv/ftp/Windows"
        sudo chown -R ftplinux:ftplinux "/srv/ftp/Linux"

        # Agregar usuarios a la lista de permitidos
        echo "ftpwindows" | sudo tee -a /etc/vsftpd.userlist
        echo "ftplinux" | sudo tee -a /etc/vsftpd.userlist

        # Asegurar que vsftpd permite solo estos usuarios
        echo "userlist_enable=YES" | sudo tee -a $VSFTPD_CONF
        echo "userlist_file=/etc/vsftpd.userlist" | sudo tee -a $VSFTPD_CONF
        echo "userlist_deny=NO" | sudo tee -a $VSFTPD_CONF

        # Abrir puertos en firewall
        echo "Configurando firewall..."
        sudo ufw allow 21/tcp

        # Reiniciar vsftpd
        echo "Reiniciando vsftpd..."
        sudo systemctl restart vsftpd

        #Apache para Windows
        sudo wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
        -P /srv/ftp/Windows/Apache/ \
        "https://www.apachelounge.com/download/VS17/binaries/httpd-2.4.63-250207-win64-VS17.zip"

        #Apache para Linux
        sudo wget -P /srv/ftp/Linux/Apache/ https://downloads.apache.org/httpd/httpd-2.4.63.tar.gz

        #Nginx para Linux
        sudo wget -P /srv/ftp/Linux/Nginx/ https://nginx.org/download/nginx-1.27.4.tar.gz
        sudo wget -P /srv/ftp/Linux/Nginx/ https://nginx.org/download/nginx-1.26.3.tar.gz
        
        #OpenLiteSpeed para Linux
        sudo wget -P /srv/ftp/Linux/OpenLiteSpeed/ https://openlitespeed.org/packages/openlitespeed-1.7.19.tgz
        sudo wget -P /srv/ftp/Linux/OpenLiteSpeed/ https://openlitespeed.org/packages/openlitespeed-1.8.3.tgz

        #Nginx para Windows
        sudo wget -P /srv/ftp/Windows/Nginx https://nginx.org/download/nginx-1.27.4.zip
        sudo wget -P /srv/ftp/Windows/Nginx https://nginx.org/download/nginx-1.26.3.zip

        #PARA CLIENTE LINUX 
        #Listar carpetas (Servicios Http)
        curl -s --user ftplinux:linux ftp://10.0.0.16 | awk '{print $NF}'
        #Listar contenido de Apache
        curl -s --user ftplinux:linux ftp://10.0.0.16/Apache/ | awk '{print $NF}'
        #Listar contenido de Nginx
        curl -s --user ftplinux:linux ftp://10.0.0.16/Nginx/ | awk '{print $NF}'
        #Listar contenido de OpenLiteSpeed
        curl -s --user ftplinux:linux ftp://10.0.0.16/OpenLiteSpeed/ | awk '{print $NF}'

        #Descargar Apache
        wget --user=ftplinux --password=linux ftp://10.0.0.16/Apache/httpd-2.4.63.tar.gz -O /tmp/httpd-2.4.63.tar.gz
        #Descargar Nginx
        wget --user=ftplinux --password=linux ftp://10.0.0.16/Nginx/nginx-1.27.4.tar.gz -O /tmp/nginx-1.27.4.tar.gz
        wget --user=ftplinux --password=linux ftp://10.0.0.16/Nginx/nginx-1.26.3.tar.gz -O /tmp/nginx-1.26.3.tar.gz
        #Descargar OpenLiteSpeed
        wget --user=ftplinux --password=linux ftp://10.0.0.16/OpenLiteSpeed/openlitespeed-1.7.19.tgz -O /tmp/openlitespeed-1.7.19.tgz
        wget --user=ftplinux --password=linux ftp://10.0.0.16/OpenLiteSpeed/openlitespeed-1.8.3.tgz -O /tmp/openlitespeed-1.8.3.tgz
    fi  
}
