#Esta funcion es para validar que el ultimo octeto de la ip final sea mayot
#al de la ip inicio, para evitar errores en la conf del dhcp
function validar_rango2 {
    param ([string]$ip1, [string]$ip2)

    $ultimo_inicio = [int]($ip1 -split "\.")[3]
    $ultimo_fin = [int]($ip2 -split "\.")[3]

    return ($ultimo_fin -le $ultimo_inicio) 
}