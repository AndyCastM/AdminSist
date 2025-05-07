# Importamos el modulo donde estaran las funciones de Active Directory
Import-Module "C:\Users\Administrador\activedirectory\adfunctions.psm1" -Force
Import-Module "C:\Users\Administrador\activedirectory\adfunctions2.psm1" -Force



while ($true) {
    Write-Host "--- P10. Active Directory PT. 2 ---" -ForegroundColor Green
    Write-Host "1. Crear Usuarios" -ForegroundColor Green
    Write-Host "2. Realizar configuraciones" -ForegroundColor Green
    Write-Host "3. Salir" -ForegroundColor Green
    $opc = Read-Host "Seleccione una opcion"

    switch ($opc){
        "1" {
            $usuario = solicitar_usuario "Ingrese nombre de usuario"
            if ([string]::IsNullOrEmpty($usuario)){
                break
            }
            $ou = menu_ou
            if ([string]::IsNullOrEmpty($ou)){
                break
            }
            Write-Host "Creando Usuario..." -ForegroundColor Green
            # Falta preguntar por el OU
            crear_usuario "$usuario" "$ou"
            Write-Host "Usuario creado exitosamente." -ForegroundColor Green
        }
        "2" {
            # Aqui van a ir las llamadas a las configuraciones
        }
        "3" {
            Write-Host "Saliendo..." -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Opcion no valida. Intente de nuevo." -ForegroundColor Red
        }
    }
}