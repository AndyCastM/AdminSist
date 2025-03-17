#!/bin/bash
# funciones/bash/variables/variables_http.sh

url_apache="https://httpd.apache.org/download.cgi"
url_nginx="https://nginx.org/en/download.html"
url_litespeed="https://openlitespeed.org/downloads/"
url_apache_descargas="https://downloads.apache.org/httpd/"
url_litespeed_descargas="https://openlitespeed.org/packages/"
url_nginx_descargas="https://nginx.org/download/"

#---PARA CERTIFICADOS SSL---
domain="10.0.0.16"
nginx_conf="/usr/local/nginx/conf/nginx.conf"
nginx_ssl_dir="/etc/nginx/ssl"
ols_conf="/usr/local/lsws/conf/httpd_config.conf"
ols_dir="/usr/local/lsws/conf/ssl"
install_dir="/usr/local/lsws"