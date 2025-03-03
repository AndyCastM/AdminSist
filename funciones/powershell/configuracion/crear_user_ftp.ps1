function CrearUsuarioFTP {
    param(
        [string]$username,
        [string]$password,
        [string]$groupName
    )
    
    # Definir rutas de carpetas principales
    $nameserver = "ServidorFTP"
    $ftpRoot = "C:\ServidorFTP"

    $ADSI = [ADSI]"WinNT://$env:ComputerName"
    
    if ($ADSI.Children | Where-Object { $_.Name -eq $username }) {
        Write-Host "El usuario ya existe." -ForegroundColor Yellow
        return
    }
    
    $newUser = $ADSI.Create("User", "$username")
    $newUser.SetPassword("$password")
    $newUser.SetInfo()
    Write-Host "Usuario $username creado." -ForegroundColor Green
    
    # Agregar usuario a grupo
    $UserAccount = New-Object System.Security.Principal.NTAccount("$username")
    $SID = $UserAccount.Translate([System.Security.Principal.SecurityIdentifier])
    $group = [ADSI]"WinNT://$env:ComputerName/$groupName,group"
    $User = [ADSI]"WinNT://$SID"
    $group.Add($User.Path)

    Write-Host "Usuario $username agregado al grupo $groupName." -ForegroundColor Green
    $group_min = $groupName.ToLower()
    # Crear carpeta personal
    $userFolder = "$ftpRoot\LocalUser\$username\$username"
    New-Item -ItemType Directory -Path $userFolder -Force

    if (-Not (Test-Path "C:\ServidorFTP\LocalUser\$username\Publica\")) {
        cmd /c mklink /d "C:\ServidorFTP\LocalUser\$username\Publica\" "C:\ServidorFTP\Publica\"
    }

    if (-Not (Test-Path "C:\ServidorFTP\LocalUser\$username\$groupName\")) {
        cmd /c mklink /d "C:\ServidorFTP\LocalUser\$username\$groupName\" "C:\ServidorFTP\$groupName\"
    }

    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="$group_min";permissions=7} -PSPath IIS:\ -Location "$nameServer/LocalUser/$username/Publica"
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="$group_min";permissions=3} -PSPath IIS:\ -Location "$nameServer/LocalUser/$username/$groupName"
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="$group_min";permissions=3} -PSPath IIS:\ -Location "$nameServer/LocalUser/$username/$username"

    # Reiniciamos el servidor FTP IIS
    Restart-WebItem "IIS:\Sites\$nameServer"
    Restart-Service ftpsvc

}