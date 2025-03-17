#!/bin/bash
# funciones/bash/configuracion/conf_CERTHTTP.sh

source "./variables/variables_http.sh"

cert_apache() {
    local port="$1"

    # Crear directorio para SSL
    sudo mkdir -p /usr/local/apache2/conf/ssl
    cd /usr/local/apache2/conf/ssl

    # Habilitar módulos SSL y caché en httpd.conf si no están habilitados
    sudo sed -i 's|#LoadModule ssl_module|LoadModule ssl_module|' /usr/local/apache2/conf/httpd.conf
    sudo sed -i 's|#LoadModule socache_shmcb_module|LoadModule socache_shmcb_module|' /usr/local/apache2/conf/httpd.conf

    # Generar certificado SSL autofirmado
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout apache-selfsigned.key -out apache-selfsigned.crt \
        -subj "/C=MX/ST=Sinaloa/L=LosMochis/O=Org/OU=IT/CN=localhost"

    # Configurar Apache para usar SSL
    sudo tee /usr/local/apache2/conf/extra/httpd-ssl.conf > /dev/null <<EOL
    <VirtualHost *:$port>
        ServerName localhost
        DocumentRoot "/usr/local/apache2/htdocs"

        SSLEngine on
        SSLCertificateFile "/usr/local/apache2/conf/ssl/apache-selfsigned.crt"
        SSLCertificateKeyFile "/usr/local/apache2/conf/ssl/apache-selfsigned.key"

        <Directory "/usr/local/apache2/htdocs">
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog "/usr/local/apache2/logs/error_log"
        CustomLog "/usr/local/apache2/logs/access_log" common
    </VirtualHost>
EOL

    # Habilitar SSL en httpd.conf
    sudo sed -i 's|#Include conf/extra/httpd-ssl.conf|Include conf/extra/httpd-ssl.conf|' /usr/local/apache2/conf/httpd.conf

    # Permitir el tráfico en el firewall
    sudo ufw allow 443/tcp

    # Reiniciar Apache
    sudo /usr/local/apache2/bin/apachectl restart
}

cert_nginx() {
    local port="$1"
    # Crear directorio para SSL si no existe
    sudo mkdir -p "$nginx_ssl_dir"

    # Generar certificado SSL autofirmado
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$nginx_ssl_dir/nginx-selfsigned.key" \
        -out "$nginx_ssl_dir/nginx-selfsigned.crt" \
        -subj "/C=MX/ST=Sinaloa/L=LosMochis/O=Org/OU=IT/CN=localhost"

    # Asegurar que la configuración de SSL existe en el archivo
    if ! grep -q "listen ${port} ssl;" "$nginx_conf"; then
        sudo sed -i "/http {/a \
        server {\n\
            listen ${port} ssl;\n\
            server_name localhost;\n\
            ssl_certificate $nginx_ssl_dir/nginx-selfsigned.crt;\n\
            ssl_certificate_key $nginx_ssl_dir/nginx-selfsigned.key;\n\
            ssl_session_cache shared:SSL:1m;\n\
            ssl_session_timeout 5m;\n\
            ssl_ciphers HIGH:!aNULL:!MD5;\n\
            ssl_prefer_server_ciphers on;\n\
            location / {\n\
                root html;\n\
                index index.html index.htm;\n\
            }\n\
        }" "$nginx_conf"
    fi

    # Verificar configuración y reiniciar Nginx
    sudo /usr/local/nginx/sbin/nginx -t && sudo /usr/local/nginx/sbin/nginx -s reload

    # Permitir tráfico HTTPS en el firewall
    sudo ufw allow 443/tcp
}


cert_ols() {
    local port="${1:-443}"
    local ols_dir="/usr/local/lsws/conf/ssl"
    local ols_conf="/usr/local/lsws/conf/httpd_config.conf"
    local vh_conf="/usr/local/lsws/conf/vhosts/Example/vhconf.conf"

    # Crear directorio para SSL si no existe
    sudo mkdir -p "$ols_dir"
    cd "$ols_dir" || exit 1

    # Generar certificado SSL autofirmado si no existe
    if [[ ! -f "litespeed-selfsigned.crt" || ! -f "litespeed-selfsigned.key" ]]; then
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout litespeed-selfsigned.key -out litespeed-selfsigned.crt \
            -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=localhost"
    fi

    # Configurar OpenLiteSpeed para usar SSL en httpd_config.conf
    if ! grep -q "listener SSL" "$ols_conf"; then
        sudo tee -a "$ols_conf" > /dev/null <<EOL

listener SSL {
    address *:$port
    secure 1
    keyFile $ols_dir/litespeed-selfsigned.key
    certFile $ols_dir/litespeed-selfsigned.crt
    map Example *
}
EOL
    fi

    # Configurar el Virtual Host para soportar HTTPS
    if [[ -f "$vh_conf" ]]; then
        sudo sed -i '/virtualHost Example {/a\
    vhssl {\n\
        enable                 1\n\
        keyFile                '$ols_dir/litespeed-selfsigned.key'\n\
        certFile               '$ols_dir/litespeed-selfsigned.crt'\n\
    }\n\
    docRoot /var/www/html\n\
    indexFiles index.html\n\
    ' "$vh_conf"
    fi

    # Verificar que la carpeta de documentos existe
    if [[ ! -d "/var/www/html" ]]; then
        sudo mkdir -p /var/www/html
        echo "<h1>OpenLiteSpeed funciona correctamente</h1>" | sudo tee /var/www/html/index.html
    fi

    # Ajustar permisos para OpenLiteSpeed
    sudo chown -R nobody:nogroup /var/www/html
    sudo chmod -R 755 /var/www/html

    # Permitir tráfico HTTPS en el firewall
    sudo ufw allow $port/tcp

    # Reiniciar OpenLiteSpeed
    sudo /usr/local/lsws/bin/lswsctrl restart
}

