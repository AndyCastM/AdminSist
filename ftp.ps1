# Verificar si IIS y el Servidor FTP están instalados
$ftpInstalled = Get-WindowsFeature Web-FTP-Server

if ($ftpInstalled.Installed -eq $false) {
    conf_ftp
} else {
    Write-Host "Servidor FTP ya está instalado." -ForegroundColor Green
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
            $password = generar_passwd
            Write-Host "Tu password es: $password" -ForegroundColor Green
            Write-Host "Seleccione el grupo:"
            Write-Host "1) Reprobados"
            Write-Host "2) Recursadores"
            $groupOption = Read-Host "Ingrese una opcion"
    
            if ($groupOption -eq "1") 
            {
                CrearUsuarioFTP -username $username -password "$password" -groupName "reprobados"
                # # Enlazar carpeta pública
                cmd /c mklink /d "C:\ServidorFTP\LocalUser\Public\Publica" "C:\ServidorFTP\Publica"
                Restart-WebItem "IIS:\Sites\ServidorFTP"
            }
            elseif ($groupOption -eq "2") {
                CrearUsuarioFTP -username $username -password "$password" -groupName "recursadores"
                # # Enlazar carpeta pública
                cmd /c mklink /d "C:\ServidorFTP\LocalUser\Public\Publica" "C:\ServidorFTP\Publica"
                Restart-WebItem "IIS:\Sites\ServidorFTP"
            }
            else {
                Write-Host "Opcion de grupo no valida." -ForegroundColor Red            
            }
        }
        "2" {
        do {
            $username = Read-Host "Ingrese nombre de usuario"
            if (-not (UsuarioExiste $username)) {
                Write-Host "El usuario NO existe. Intenta de nuevo." -ForegroundColor Red
            }
            } until (UsuarioExiste $username)

            Write-Host "Seleccione el grupo:"
            Write-Host "1) Reprobados"
            Write-Host "2) Recursadores"
            $newGroup = Read-Host "Nuevo grupo:"
                
            if ($newGroup -eq "1") 
            {
                CambiarGrupo -username $username -newGroup "reprobados"            
            }
            elseif ($newGroup -eq "2") {
                CambiarGrupo -username $username -newGroup "recursadores"            
            }
            else {
                Write-Host "Opcion de grupo no valida." -ForegroundColor Red            
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