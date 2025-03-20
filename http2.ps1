Import-Module "C:\Users\Administrador\AdminSist\HTTP.psm1"

# Verifica si el script se está ejecutando como Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como Administrador." -ForegroundColor Red
    exit
}

while ($true) {
    menu_http3
    $op = Read-Host "Elija una opcion (1-2):"

    switch ($op) {
        "1" {
            Write-Host "Opcion 1 seleccionada: Web" -ForegroundColor Cyan
            while ($true) {
                menu_http
                $op = Read-Host "Elija el servicio HTTP que desea configurar (1-3):"
                if ([string]::IsNullOrEmpty($op)){
                    break
                }
                switch ($op) {
                    "1" {
                        $port = solicitar_puerto "Ingresa el puerto para IIS (1024-65535):"
                        if ([string]::IsNullOrEmpty($port)){
                            continue
                        }
                        conf_IIS -port "$port"
                        menu_cert
                        do {
                            $op2 = Read-Host "Elija una opcion (1-2)"
                            if ($op2 -match "^[12]$") {
                                break
                            } else {
                                Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
                            }
                        } while ($true)
                        
                        if ($op2 -eq "1") {
                            Write-Host "Configurando certificado SSL..."
                            cert_IIS -port "$port"
                        } else {
                            Write-Host "No se configurara SSL."
                        }
                    }
                    "2" {
                        $version= obtener_apache
                        $op2 = Read-Host "Selecciona 1 para instalar Apache"
                        while ($true){
                            if ($op2 -eq "1") {
                                $port = solicitar_puerto "Ingresa el puerto para Apache (1024-65535)"
                                if ([string]::IsNullOrEmpty($port)){
                                    continue
                                }
                                conf_apache -port $port -version "$version"
                                menu_cert
                                do {
                                    $op2 = Read-Host "Elija una opcion (1-2)"
                                    if ($op2 -match "^[12]$") {
                                        break
                                    } else {
                                        Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
                                    }
                                } while ($true)
                                
                                if ($op2 -eq "1") {
                                    Write-Host "Configurando certificado SSL..."
                                    cert_apache -port "$port"
                                } else {
                                    Write-Host "No se configurará SSL."
                                }
                                break
                            } elseif ($op2 -eq "2") {
                                Write-Host "Regresando al menu principal." -ForegroundColor Yellow
                                break
                            } else {
                                Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
                            }
                        }
                    }
                    "3" {
                        $version= obtener_nginx
                        do {
                            menu_http2 "Nginx" $version.stable $version.mainline
                            $op2 = Read-Host "Seleccione una opcion (1-3):"
                            if ($op2 -eq "1"){
                                $port = solicitar_puerto "Ingresa el puerto para Nginx (1024-65535)"
                                if ([string]::IsNullOrEmpty($port)){
                                    break
                                }
                                conf_nginx -port $port -version $version.stable
                                break
                            } elseif ($op2 -eq "2"){
                                $port = solicitar_puerto "Ingresa el puerto para Nginx (1024-65535)"
                                if ([string]::IsNullOrEmpty($port)){
                                    break
                                }
                                conf_nginx -port $port -version $version.mainline
                                break
                            } elseif ($op2 -eq "3"){
                                Write-Host "Regresando al menu principal." -ForegroundColor Yellow
                                return
                            } else {
                                Write-Host "Opcion no valida. Intente de nuevo." -ForegroundColor Yellow
                            }
                        } while ($true)

                        menu_cert
                        do {
                            $op2 = Read-Host "Elija una opcion (1-2)"
                            if ($op2 -match "^[12]$") {
                                break
                            } else {
                                Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
                            }
                        } while ($true)
                                            
                        if ($op2 -eq "1") {
                            Write-Host "Configurando certificado SSL..."
                            cert_nginx -port "$port"
                        } else {
                            Write-Host "No se configurará SSL."
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
        }
        "2" {
            Write-Host "Opcion 2 seleccionada: FTP" -ForegroundColor Cyan
            ftphttp
        }
        "3"{
            Write-Host "Saliendo..."
            exit
        }
        default {
            Write-Host "Opcion no valida." -ForegroundColor Red
        }
    }

}