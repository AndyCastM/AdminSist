function validar_rango {
    param ([string]$ip1, [string]$ip2)
    return (($ip1 -split "\.")[0..2] -join ".") -eq (($ip2 -split "\.")[0..2] -join ".")
}
