$global:regPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System"

# UOs 
$global:ouPathC = "OU=cuates,DC=plan-tres,DC=com"
$global:ouPathNC = "OU=no cuates,DC=plan-tres,DC=com"

# GPOs de restricción de archivos
$global:gpoTam1 = "Grupo1Tam"
$global:gpoTam2 = "Grupo2Tam"

$global:gpoApp1 = "SoloBlocNotas"
$global:gpoApp2 = "BloquearBlocNotas"

# 3 y 4
function restriccion_archivos(){
    # Variables
    $sharePath = "C:\Profiles\"
    $serverName = "DC"  #CAMBIAR ESTO A TU NOMBRE DE SERVER
    $shareName = "Profiles"

    ################################### GRUPO 1- CUATES ######################################### 
    # Crear GPO
    New-GPO -Name $global:gpoTam1 -ErrorAction SilentlyContinue

    # Enlazar GPO a la OU CORRECTA
    New-GPLink -Name $global:gpoTam1 -Target $global:ouPathC -LinkEnabled Yes

    # Configurar claves del Registro en GPO para límite de perfil (5MB)
    Set-GPRegistryValue -Name $global:gpoTam1 -Key $global:regPath -ValueName EnableProfileQuota -Type DWord -Value 1
    Set-GPRegistryValue -Name $global:gpoTam1 -Key $global:regPath -ValueName IncludeProfileQuota -Type DWord -Value 1
    Set-GPRegistryValue -Name $global:gpoTam1 -Key $global:regPath -ValueName MaxProfileSize -Type DWord -Value 5000  # 5MB en KB
    Set-GPRegistryValue -Name $global:gpoTam1 -Key $global:regPath -ValueName ProfileQuotaMessage -Type String -Value "Te pasaste de tamanio Cuate"
    Set-GPRegistryValue -Name $global:gpoTam1 -Key $global:regPath -ValueName WarnUser -Type DWord -Value 1
    Set-GPRegistryValue -Name $global:gpoTam1 -Key $global:regPath -ValueName WarnUserTimeout -Type DWord -Value 10

    ################################### GRUPO 2- NO CUATES ######################################### 
    # Crear GPO
    New-GPO -Name $global:gpoTam2  -ErrorAction SilentlyContinue

    # Enlazar GPO a la OU CORRECTA
    New-GPLink -Name $global:gpoTam2 -Target $global:ouPathNC -LinkEnabled Yes

    # Configurar claves del Registro en GPO para límite de perfil (10MB)
    Set-GPRegistryValue -Name $global:gpoTam2 -Key $global:regPath -ValueName EnableProfileQuota -Type DWord -Value 1
    Set-GPRegistryValue -Name $global:gpoTam2 -Key $global:regPath -ValueName IncludeProfileQuota -Type DWord -Value 1
    Set-GPRegistryValue -Name $global:gpoTam2 -Key $global:regPath -ValueName MaxProfileSize -Type DWord -Value 10000  # 10MB en KB
    Set-GPRegistryValue -Name $global:gpoTam2 -Key $global:regPath -ValueName ProfileQuotaMessage -Type String -Value "Tu no eres cuate, te pasaste"
    Set-GPRegistryValue -Name $global:gpoTam2 -Key $global:regPath -ValueName WarnUser -Type DWord -Value 1
    Set-GPRegistryValue -Name $global:gpoTam2 -Key $global:regPath -ValueName WarnUserTimeout -Type DWord -Value 10

    # Configuración compartida para ambos grupos 
    # Crear carpeta compartida para perfiles
    New-Item -ItemType Directory -Name Profiles -Path C:\
    New-SmbShare -Path $sharePath -Name $shareName 
    Grant-SmbShareAccess -Name $shareName -AccountName Todos -AccessRight Full 

    # Para asignar a todos los usuarios en OU CUATES
    $usersC = Get-ADUser -Filter * -SearchBase $global:ouPathC
    foreach ($user in $usersC) {
        $profilePath = "\\$serverName\$shareName\$($user.SamAccountName)"
        Set-ADUser -Identity $($user.SamAccountName) -ProfilePath $profilePath
    }

    # Para asignar a todos los usuarios en OU NO CUATES
    $usersNC = Get-ADUser -Filter * -SearchBase $global:ouPathNC
    foreach ($user in $usersNC) {
        $profilePath = "\\$serverName\$shareName\$($user.SamAccountName)"
        Set-ADUser -Identity $($user.SamAccountName) -ProfilePath $profilePath
    }

    # Actualizar directivas
    Invoke-GPUpdate -Force
    gpupdate /force
}

# 5 y 6
function restriccion_aplicaciones(){

    ####### HABILITAR SOLO BLOC DE NOTAS - CUATES ########

    New-GPO -Name $global:gpoApp1

    New-GPLink -Name $global:gpoApp1 -Target $global:ouPathC

    Set-GPRegistryValue -Name $global:gpoApp1 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "RestrictRun" -Type DWord -Value 1

    Set-GPRegistryValue -Name $global:gpoApp1  -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\RestrictRun" -ValueName "1" -Type String -Value "notepad.exe"

    ####### BLOQUEAR BLOC DE NOTAS - CUATES ########
    #Vincular la GPO "BloquearBlocNotas" a la UO "cuates"

    New-GPO -Name $global:gpoApp2

    New-GPLink -Name $global:gpoApp2 -Target $global:ouPathNC

    #Habilitar la política para bloquear las aplicaciones especificadas
    Set-GPRegistryValue -Name $global:gpoApp2 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName DisallowRun -Type DWord -Value 1

    #Especificar la lista de aplicaciones bloqueadas (solo el Bloc de Notas)
    Set-GPRegistryValue -Name $global:gpoApp2 -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\DisallowRun" -ValueName 1 -Type String -Value "notepad.exe"

    # CLIENTE
    # gpupdate /force
    # gpresult /r /scope:user

}

function passwords_seguras(){
    Set-ADDefaultDomainPasswordPolicy -Identity "plan-tres.com" `
    -MinPasswordLength 8 `
    -ComplexityEnabled $true `
    -PasswordHistoryCount 1 `
    -MinPasswordAge "1.00:00:00" `
    -MaxPasswordAge "30.00:00:00"

    #Para checar la nueva politica de contraseña
    Get-ADDefaultDomainPasswordPolicy

    # Para exigir cambio de contraseña de usuario ya creado
    # Para exigir a todos los usuarios en OU CUATES
    $usersC = Get-ADUser -Filter * -SearchBase $global:ouPathC
    foreach ($user in $usersC) {
        Set-ADUser -Identity $($user.SamAccountName) -ChangePasswordAtLogon $true
    }

    # Para exigir a todos los usuarios en OU NO CUATES
    $usersNC = Get-ADUser -Filter * -SearchBase $global:ouPathNC
    foreach ($user in $usersNC) {
        Set-ADUser -Identity $($user.SamAccountName) -ChangePasswordAtLogon $true
    }
}

# 8
function habilitar_auditorias {
    # Ejecutar auditpol como comando externo
    Start-Process -FilePath "auditpol.exe" -ArgumentList "/set /category:`"Inicio/cierre de sesión`" /success:enable /failure:enable" -NoNewWindow -Wait
    Start-Process -FilePath "auditpol.exe" -ArgumentList "/set /category:`"Inicio de sesión de la cuenta`" /success:enable /failure:enable" -NoNewWindow -Wait

    # Subcategorías específicas
    Start-Process -FilePath "auditpol.exe" -ArgumentList "/set /subcategory:`"Acceso del servicio de directorio`" /success:enable /failure:enable" -NoNewWindow -Wait
    Start-Process -FilePath "auditpol.exe" -ArgumentList "/set /subcategory:`"Cambios de servicio de directorio`" /success:enable /failure:enable" -NoNewWindow -Wait

    Start-Process -FilePath "auditpol.exe" -ArgumentList "/set /subcategory:`"Administración de cuentas de usuario`" /success:enable /failure:enable" -NoNewWindow -Wait
    Start-Process -FilePath "auditpol.exe" -ArgumentList "/set /subcategory:`"Administración de cuentas de grupos de seguridad`" /success:enable /failure:enable" -NoNewWindow -Wait
    Start-Process -FilePath "auditpol.exe" -ArgumentList "/set /subcategory:`"Administración de cuentas de equipo`" /success:enable /failure:enable" -NoNewWindow -Wait
}
