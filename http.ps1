#HTTP   

# Verifica si el script se está ejecutando como Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como Administrador." -ForegroundColor Red
    exit
}

while ($true) {
    menu_http
    $op = Read-Host "Elija el servicio HTTP que desea configurar (1-3):"

    switch ($op) {
        "1" {
            $port = solicitar_puerto "Ingresa el puerto para IIS (1024-65535):"
            if ([string]::IsNullOrEmpty($port)){
                continue
            }
            conf_IIS -port "$port"
        }
        "2" {
            $version= obtener_apache
            $op2 = Read-Host "Selecciona 1 para instalar Apache"
            if ($op2 -eq "1") {
                $port = solicitar_puerto "Ingresa el puerto para Apache (1024-65535)"
                if ([string]::IsNullOrEmpty($port)){
                    continue
                }
                conf_apache -port $port -version "$version"
            } else {
                Write-Host "Regresando al menu principal." -ForegroundColor Yellow
            }
        }
        "3" {
            $version= obtener_nginx
            menu_http2 "Nginx" $version.stable $version.mainline
            $op2 = Read-Host "Seleccione una opcion (1-3):"
            if ($op2 -eq "1"){
                $port = solicitar_puerto "Ingresa el puerto para Nginx (1024-65535)"
                if ([string]::IsNullOrEmpty($port)){
                    continue
                }
                conf_nginx -port $port -version $version.stable
            } elseif ($op2 -eq "2"){
                $port = solicitar_puerto "Ingresa el puerto para Nginx (1024-65535)"
                if ([string]::IsNullOrEmpty($port)){
                    continue
                }
                conf_nginx -port $port -version $version.mainline
            } elseif ($op2 -eq "3"){
                Write-Host "Regresando al menu principal." -ForegroundColor Yellow
            } else {
                Write-Host "Opcion no valida. Regresando al menu principal." -ForegroundColor Yellow
            }
        }
        "4" {
            exit
        }
        default {
            Write-Host "Opcion no valida." -ForegroundColor Red
        }
    }


}