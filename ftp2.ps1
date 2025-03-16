# Verificar si IIS y el Servidor FTP están instalados
$ftpInstalled = Get-WindowsFeature Web-FTP-Server

Import-Module "C:\Users\Administrador\AdminSist\Entrada.psm1"
Import-Module "C:\Users\Administrador\AdminSist\Validacion.psm1"
Import-Module "C:\Users\Administrador\AdminSist\Configuracion.psm1"

if ($ftpInstalled.Installed -eq $false) {
    conf_ftp_sincert
} else {
    Write-Host "Servidor FTP ya esta instalado." -ForegroundColor Green
}

$IPAddress = [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName()) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1
$certeliminar = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object { $_.Subject -eq "CN=${IPAddress}" }

# Verificar que se haya obtenido el certificado
if ($certeliminar -ne $null) {
    Write-Host "Servidor FTP previamente configurado con certificado SSL." -ForegroundColor Green
} else {
    while ($true){
        Write-Host "Desea configurar su servidor FTP con certificado SSL? 1 - Si, 2 - No"
        $option = Read-Host "Seleccione una opcion"
        if ($option -eq "1") {
            crearCERT
            break
        } elseif ($option -eq "2") {
            break
        } else {
            Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
        }
    }
}

while ($true) {
    Write-Host "--- SERVIDOR FTP ---" -ForegroundColor Cyan
    Write-Host "1. Crear usuario FTP"
    Write-Host "2. Cambiar usuario de grupo"
    Write-Host "3. Salir"
    
    $option = Read-Host "Seleccione una opcion"
    
    switch ($option) {
        "1" {
            $username = solicitar_user "Ingrese nombre de usuario"
            if ([string]::IsNullOrEmpty($username)){
                continue
            }
            $password = generar_passwd
            Write-Host "Tu password es: $password" -ForegroundColor Green

            while ($true) {
                Write-Host "Seleccione el grupo:"
                Write-Host "1) Reprobados"
                Write-Host "2) Recursadores"
                $groupOption = Read-Host "Ingrese una opcion"
                if ([string]::IsNullOrEmpty($groupOption)){
                    break
                }
                if ($groupOption -eq "1") 
                {
                    CrearUsuarioFTP -username $username -password "$password" -groupName "reprobados"
                    # # Enlazar carpeta pública
                    # cmd /c mklink /d "C:\ServidorFTP\LocalUser\Public\Publica" "C:\ServidorFTP\Publica" 
                    Restart-WebItem "IIS:\Sites\ServidorFTP"
                    break
                }
                elseif ($groupOption -eq "2") {
                    CrearUsuarioFTP -username $username -password "$password" -groupName "recursadores"
                    # # Enlazar carpeta pública
                    # cmd /c mklink /d "C:\ServidorFTP\LocalUser\Public\Publica" "C:\ServidorFTP\Publica" 
                    Restart-WebItem "IIS:\Sites\ServidorFTP"
                    break
                }
                else {
                    Write-Host "Opcion de grupo no valida." -ForegroundColor Red            
                }
            } 
        }
        "2" {
            while ($true) {
                $username = Read-Host "Ingrese nombre de usuario"
                
                # Si el usuario no ingresa nada, salir del menú
                if ([string]::IsNullOrEmpty($username)) {
                    Write-Host "Operacion cancelada." -ForegroundColor Yellow
                    break
                }
        
                # Verificar si el usuario existe
                if (UsuarioExiste $username) {
                    break
                } else {
                    Write-Host "El usuario NO existe. Intente de nuevo." -ForegroundColor Red
                }       

                Write-Host "Seleccione el grupo:"
                Write-Host "1) Reprobados"
                Write-Host "2) Recursadores"
                $newGroup = Read-Host "Nuevo grupo:"
                if ([string]::IsNullOrEmpty($newGroup)){
                    Write-Host "Operacion cancelada." -ForegroundColor Yellow
                    break
                }
                    
                if ($newGroup -eq "1") 
                {
                    CambiarGrupo -username $username -newGroup "reprobados"       
                    break     
                }
                elseif ($newGroup -eq "2") {
                    CambiarGrupo -username $username -newGroup "recursadores"    
                    break        
                }
                else {
                    Write-Host "Opcion de grupo no valida." -ForegroundColor Red            
                }
            }
        }
        "3" {
            exit
        }
        default {
            Write-Host "Opcion no valida." -ForegroundColor Red
        }
    }
}