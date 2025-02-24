function conf_dhcp {
    param (
        [string]$ipFija, 
        [string]$ipInicio, 
        [string]$ipFin
    )

    $partes = $ipFija -split "\."
    $ipscope = ($partes[0..2] -join ".") + ".0"
    $gateway = ($partes[0..2] -join ".") + ".1"

    try {
        Write-Host "Configurando IP y servicio DHCP..." -ForegroundColor Green
        fijar_ip $ipFija "Ethernet 2"

        # Verificar si DHCP ya está instalado
        $dhcpInstalled = Get-WindowsFeature -Name DHCP
        if (-not $dhcpInstalled.Installed) {
            Write-Host "Instalando servicio DHCP..." -ForegroundColor Green
            Install-WindowsFeature -Name DHCP -IncludeManagementTools -ErrorAction Stop
        } else {
            Write-Host "DHCP ya está instalado." -ForegroundColor Yellow
        }

        # Configurar el ámbito DHCP
        Write-Host "Configurando ámbito IPv4..." -ForegroundColor Green
        Add-DhcpServerv4Scope -Name "Red-Interna Andrea" -StartRange $ipInicio -EndRange $ipFin -SubnetMask 255.255.255.0 -State Active -ErrorAction Stop

        # Configurar puerta de enlace
        Write-Host "Configurando puerta de enlace..." -ForegroundColor Green
        Set-DhcpServerv4OptionValue -ScopeId $ipscope -OptionId 3 -Value $gateway -ErrorAction Stop

        Write-Host "Servicio DHCP configurado correctamente." -ForegroundColor Green

        # Retornar un objeto con los resultados
        return @{
            Status = "Configuración exitosa"
            IPFija = $ipFija
            Rango  = "$ipInicio - $ipFin"
            Gateway = $gateway
            Scopes = $ipscope
        }

    } catch {
        Write-Host "Error durante la configuración: $_" -ForegroundColor Red
        return $null
    }
}
