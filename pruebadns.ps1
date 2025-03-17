$ipFija = solicitar_ip "Introduce la direccion IP que quieres fijar"
$dominio = solicitar_dom "Introduce el dominio a configurar"

conf_dns "$ipFija" "$dominio"