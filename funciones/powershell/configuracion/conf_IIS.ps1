function conf_IIS {
    param( [string]$port )
    
    # Instalar IIS si no está instalado
    if (-not (Get-WindowsFeature -Name Web-Server).Installed) {
        Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    }

    # Habilitar el puerto en el firewall
    New-NetFirewallRule -DisplayName "IIS Port $port" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port -ErrorAction SilentlyContinue

    # Importar módulo de administración de IIS
    Import-Module WebAdministration

    # Remover el binding HTTP existente en el puerto 80
    Remove-WebBinding -Name "Default Web Site" -Protocol "http" -Port 80 -ErrorAction SilentlyContinue

    # Agregar un nuevo binding con el puerto seleccionado
    New-WebBinding -Name "Default Web Site" -Protocol "http" -Port $port -IPAddress "*"

    # Reiniciar IIS para aplicar los cambios
    iisreset
}
