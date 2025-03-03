function CambiarGrupo {
    param(
        [string]$username,
        [string]$newGroup
    )
    
    # Definir rutas de carpetas principales
    $nameserver = "ServidorFTP"
    $ftpRoot = "C:\ServidorFTP"

    $oldGroup = "reprobados"
    if ($newGroup -eq "reprobados") { $oldGroup = "recursadores" }
    
    $groupOld = [ADSI]"WinNT://$env:ComputerName/$oldGroup,group"
    
    if ($groupOld.Members() -contains "WinNT://$env:ComputerName/$username,user") {
        $groupOld.Remove("WinNT://$env:ComputerName/$username,user")
    }
    
    $UserAccount = New-Object System.Security.Principal.NTAccount("$username")
    $SID = $UserAccount.Translate([System.Security.Principal.SecurityIdentifier])
    $groupNew = [ADSI]"WinNT://$env:ComputerName/$newGroup,group"
    $User = [ADSI]"WinNT://$SID"
    $groupNew.Add($User.Path)

    $enlace_viejo = "$ftpRoot\LocalUser\$username\$oldGroup\"
    $enlace_nuevo = "$ftpRoot\LocalUser\$username\$newGroup\"
    $enlace_carpeta = "C:\ServidorFTP\$newGroup\"
    # Eliminar enlace simbólico si existe
    if (Test-Path $enlace_viejo) {
        Remove-Item $enlace_viejo -Force
        Write-Host "Enlace simbólico eliminado: $enlace_viejo" -ForegroundColor Yellow
    }

    # Crear nuevo enlace simbólico al nuevo grupo
    cmd /c mklink /d "$enlace_nuevo" "$enlace_carpeta"
    Write-Host "Nuevo enlace simbólico creado: $enlace_nuevo → $enlace_carpeta" -ForegroundColor Green

    Write-Host "Usuario $username movido a $newGroup." -ForegroundColor Green
    
    # Reiniciamos el servidor FTP IIS
    Restart-WebItem "IIS:\Sites\$nameServer"
    Restart-Service ftpsvc
}