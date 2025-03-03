function CambiarGrupo {
    param(
        [string]$username,
        [string]$newGroup
    )
    
    # Definir rutas de carpetas principales
    $nameServer = "ServidorFTP"
    $ftpRoot = "C:\ServidorFTP"

    $oldGroup = "reprobados"
    if ($newGroup -eq "reprobados") { $oldGroup = "recursadores" }
    
    $groupOld = [ADSI]"WinNT://$env:ComputerName/$oldGroup,group"
    $miembrosGrupo = @($groupOld.Invoke("Members")) | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }

    if ($miembrosGrupo -contains $username) {
        $groupOld.Remove("WinNT://$env:ComputerName/$username,user")
    } 
    
    $UserAccount = New-Object System.Security.Principal.NTAccount("$username")
    $SID = $UserAccount.Translate([System.Security.Principal.SecurityIdentifier])
    $groupNew = [ADSI]"WinNT://$env:ComputerName/$newGroup,group"
    $User = [ADSI]"WinNT://$SID"

    # Verificar si el usuario ya está en el grupo antes de agregarlo
    $miembrosGrupo2 = @($groupNew.Invoke("Members")) | ForEach-Object { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }

    if ($miembrosGrupo2 -contains $username) {
        Write-Host "El usuario ya pertenece al grupo" -ForegroundColor DarkYellow
        return
    } else {
        $groupNew.Add($User.Path)
        Write-Host "Usuario $username agregado al grupo $newGroup." -ForegroundColor Green
    }

    $enlace_viejo = "$ftpRoot\LocalUser\$username\$oldGroup\"
    $enlace_nuevo = "$ftpRoot\LocalUser\$username\$newGroup\"
    $enlace_carpeta = "C:\ServidorFTP\$newGroup\"
    # Eliminar enlace simbólico si existe
    if (Test-Path $enlace_viejo) {
        Remove-Item $enlace_viejo -Recurse -Force -Confirm:$false
        Write-Host "Enlace simbólico eliminado: $enlace_viejo" -ForegroundColor Yellow
    }

    # Crear nuevo enlace simbólico al nuevo grupo
    cmd /c mklink /d "$enlace_nuevo" "$enlace_carpeta"
    Write-Host "Nuevo enlace simbólico creado: $enlace_nuevo → $enlace_carpeta" -ForegroundColor Green

    # Reiniciamos el servidor FTP IIS
    Restart-WebItem "IIS:\Sites\$nameServer"
    Restart-Service ftpsvc
}