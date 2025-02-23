#Valida que dos ips pertenezcan a la misma subred
function validar_rango {
    param ([string]$ip1, [string]$ip2)

    # Divide las IP en arrays de números
    $partes = $ip1 -split "\."
    $partes2 = $ip2 -split "\."
    $ip_i = ($partes[0..2] -join ".") 
    $ip_a = ($partes2[0..2] -join ".")  
     
    # Comparar los primeros tres octetos
    return ($ip_i -eq $ip_a)
}