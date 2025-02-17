#Castellanos Martínez Andrea
function validar_ip {
    param (
        [string]$ip
    )

    $regex = "^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-4]|2[0-4][0-9]|1?[0-9][0-9]?))$"
    
    if ($ip -match $regex) {
        $partes = $ip -split "\."
        if ($partes[3] -eq "1" -or $partes[3] -eq "255") {
            return $false 
        } else {
            return $true
        }
    } else {
        return $false
    }
}

# Pedir IP hasta que sea válida
do {
    $ip = Read-Host "Introduce la direccion IP que quieres fijar"
    if (-not(validar_ip $ip)) {
        Write-Output "IP no valida."
    } else {
        Write-Output "IP valida: $ip"
    }
} until (validar_ip $ip)

$verdadero = $false
do {
    $inicio = Read-Host "Introduce la direccion IP del inicio del rango de red"
    $partes = $ip -split "\."
    $ip_i = ($partes[0..2] -join ".") 
    $partes2 = $inicio -split "\."
    $ip_a = ($partes2[0..2] -join ".")  

    if ($ip_i -ne $ip_a) {
        Write-Output "La IP de inicio debe pertenecer al mismo rango de red que la IP fijada."
        continue
    } 

    if (-not(validar_ip $inicio)) {
        Write-Output "IP no valida."
    } else {
        Write-Output "IP valida: $inicio"
        $verdadero = $true
    }
} until ($verdadero)

$verdadero = $false
do {
    $fin = Read-Host "Introduce la direccion IP de fin del rango de red"

    $partes2 = $inicio -split "\."
    $ip_a = ($partes2[0..2] -join ".")  
    $partes3 = $fin -split "\."
    $ip_b = ($partes3[0..2] -join ".")

    if ($ip_a -ne $ip_b) {
        Write-Output "La IP de fin debe pertenecer al mismo rango de red que la IP de inicio."
        continue
    }

    # Comparar los últimos octetos de las IPs de inicio y fin (numéricamente)
    $ultimo_inicio = [int]($inicio -split "\.")[3]
    $ultimo_fin = [int]($fin -split "\.")[3]

    if ($ultimo_fin -le $ultimo_inicio) {
        Write-Output "La IP de fin debe ser mayor a la IP de inicio."
        continue
    }

    if (-not(validar_ip $fin)) {
        Write-Output "IP no valida."
    } else {
        Write-Output "IP valida: $fin"
        $verdadero = $true
    }
} until ($verdadero)

$ipscope = ($partes[0..2] -join ".") + ".0"
$gateway = ($partes[0..2] -join ".") + ".1"

Write-Host "Rangos de red $inicio - $fin" -ForegroundColor Green
Write-Host "Submascara $subnetmask" -ForegroundColor Green

Write-Host "Fijando IP..." -ForegroundColor Green
New-NetIPAddress -IPAddress $ip -InterfaceAlias "Ethernet 2" -PrefixLength 24

$partes = $ip -split "\."
$ipscope = ($partes[0..2] -join ".") + ".0"
$gateway = ($partes[0..2] -join ".") + ".1"

#Instalar el servicio DHCP
Write-Host "Instalando servicio DHCP..." -ForegroundColor Green
Install-WindowsFeature -Name DHCP -IncludeManagementTools

#Configurar un ambito IPv4
Write-Host "Configurando ambito IPv4..." -ForegroundColor Green
Add-DhcpServerv4Scope -Name "Red-Interna Andrea" -StartRange $inicio -EndRange $fin -SubnetMask 255.255.255.0 -State Active

#Configurar la puerta de enlace
Write-Host "Configurando puerta de enlace..." -ForegroundColor Green
Set-DhcpServerv4OptionValue -ScopeId $ipscope -OptionId 3 -Value $gateway

#Ver los ambitos configurados
Get-DhcpServerv4Scope

Write-Host "Servicio DHCP configurado correctamente." -ForegroundColor Green

