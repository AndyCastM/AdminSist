#Para la entrada de datos de ip final y validacion con ip inicio
function solicitar_rango2 {
    param ([string]$mensaje, [string]$ipReferencia)
    
    do {
        $ip = solicitar_rango $mensaje $ipReferencia

        if (validar_rango2 $ipReferencia $ip) {
            Write-Host "La IP final debe de ser mayor a la IP de inicio" -ForegroundColor Red
        }
        else
        {
            Write-Host "IP válida"
        }
    } until (-not (validar_rango2 $ipReferencia $ip))
    return $ip
}