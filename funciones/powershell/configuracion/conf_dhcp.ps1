# Importar funciones
. "$PSScriptRoot/funciones/entrada/solicitar_ip.ps1"
. "$PSScriptRoot/funciones/entrada/solicitar_rango.ps1"


function conf_dhcp {
    param param ([string]$ipFija, [string]$ipInicio, [string]$ipFin )
}

# Configuración de red
$ipscope = ($ipFija -split "\.")[0..2] -join "." + ".0"
$gateway = ($ipFija -split "\.")[0..2] -join "." + ".1"

Write-Host "Configurando IP y servicio DHCP..." -ForegroundColor Green
New-NetIPAddress -IPAddress $ipFija -InterfaceAlias "Ethernet 2" -PrefixLength 24

Write-Host "Instalando servicio DHCP..." -ForegroundColor Green
Install-WindowsFeature -Name DHCP -IncludeManagementTools

Write-Host "Configurando ámbito IPv4..." -ForegroundColor Green
Add-DhcpServerv4Scope -Name "Red-Interna Andrea" -StartRange $ipInicio -EndRange $ipFin -SubnetMask 255.255.255.0 -State Active

Write-Host "Configurando puerta de enlace..." -ForegroundColor Green
Set-DhcpServerv4OptionValue -ScopeId $ipscope -OptionId 3 -Value $gateway

Write-Host "Ámbitos configurados:" -ForegroundColor Green
Get-DhcpServerv4Scope

Write-Host "Servicio DHCP configurado correctamente." -ForegroundColor Green
