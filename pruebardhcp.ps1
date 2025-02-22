#Importar funciones
$env:PSModulePath += ";C:\Program Files\WindowsPowerShell\Modules\"
Import-Module AdminSist

$ipFija = solicitar_ip "Introduce la direccion IP que quieres fijar"
$ipInicio = solicitar_rango "Introduce la direccion IP de inicio del rango" $ipFija
$ipFin = solicitar_rango "Introduce la direccion IP de fin del rango de red" $ipInicio