function conf_dns {
    param (
        [string]$ip, 
        [string]$dominio
    )

    Write-Host "Bienvenido a la configuración de tu servidor DNS" -ForegroundColor Green
    $partes = $ip -split "\."
    $partes[3] = "0"
    $IPScope = ($partes[0..2] -join ".") + ".0/24"
    $NetworkID = ($partes[2..0] -join ".") + ".in-addr.arpa.dns"
    Write-Host "Dirección IP separada por partes" -ForegroundColor Green
    
    #Fijar IP
    try {
        Write-Host "Fijando IP..." -ForegroundColor Green
        fijar_ip $ip "Ethernet 2"

        #Instalar servidor DNS
        Write-Host "Instalando servidor DNS..." -ForegroundColor Green
        Install-WindowsFeature -Name DNS -IncludeManagementTools

        #Configurar zona principal
        Write-Host "Configurando zona principal..." -ForegroundColor Green
        Add-DnsServerPrimaryZone -Name $dominio -ZoneFile "$dominio.dns" -DynamicUpdate None -PassThru 

        #Configurar zona inversa
        Write-Host "Configurando zona inversa..." -ForegroundColor Green
        Add-DnsServerPrimaryZone -NetworkID $IPScope -ZoneFile $NetworkID -DynamicUpdate None -PassThru

        #Crear registro A para dominio principal
        Write-Host "Creando registro A para dominio principal: $dominio" -ForegroundColor Green
        Add-DnsServerResourceRecordA -Name "@" -ZoneName $dominio -IPv4Address $ip -CreatePtr -PassThru

        #Crear registro para www
        Write-Host "Creando registro A para www.$dominio" -ForegroundColor Green
        Add-DnsServerResourceRecordA -Name "www" -ZoneName $dominio -IPv4Address $ip -CreatePtr -PassThru

        #Configurar máquina como servidor DNS
        Write-Host "Configurando máquina como servidor DNS..." -ForegroundColor Green
        Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $ip
        Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses $ip

        #Reiniciar servicio DNS
        Write-Host "Reiniciando servicio DNS..." -ForegroundColor Green
        Restart-Service -Name DNS

        #Habilitar pruebas ping 
        New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -Direction Inbound -Action Allow

        Write-Host "Configuración finalizada. Puedes probar tu servidor DNS :)" -ForegroundColor Green
        
        # Retornar un objeto con los resultados
        return @{
            Status = "Configuración exitosa"
            IPFija = $ip
            Doninio = $dominio
        }
    } catch {
        Write-Host "Error durante la configuración: $_" -ForegroundColor Red
        return $null
    }

}