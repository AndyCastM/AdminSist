$global:regPath = "HKCU\Software\Policies\Microsoft\Windows\System"

# UOs 
$global:ouPathC = "OU=cuates,DC=plan-tres,DC=com"
$global:ouPathNC = "OU=no cuates,DC=plan-tres,DC=com"

# GPOs de restricción de archivos
$global:gpoTam1 = "Grupo1Tam"
$global:gpoTam2 = "Grupo2Tam"

function restriccion_archivos(){
    # Variables
    $sharePath = "C:\Profiles"
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
    New-Item -ItemType Directory -Path $sharePath -Force | Out-Null
    New-SmbShare -Path $sharePath -Name $shareName -FullAccess "Todos" -ErrorAction SilentlyContinue
    Grant-SmbShareAccess -Name $shareName -AccountName "Todos" -AccessRight Full -Force

    # Para asignar a todos los usuarios en OU CUATES
    $usersC = Get-ADUser -Filter * -SearchBase $global:ouPathC
    foreach ($user in $usersC) {
        $profilePath = "\\$serverName\$shareName\$($user.SamAccountName)"
        Set-ADUser -Identity $user -ProfilePath $profilePath
    }

    # Para asignar a todos los usuarios en OU NO CUATES
    $usersNC = Get-ADUser -Filter * -SearchBase $global:ouPathNC
    foreach ($user in $usersNC) {
        $profilePath = "\\$serverName\$shareName\$($user.SamAccountName)"
        Set-ADUser -Identity $user -ProfilePath $profilePath
    }

    # Actualizar directivas
    Invoke-GPUpdate -Force
    gpupdate /force
}

function restriccion_aplicaciones(){
    #Crear la GPO para bloquear todas las aplicaciones excepto el bloc de notas
    $gpo1 = New-GPO -Name "SoloBlocNotas"

    #Obtener la GPO creada
    $gpo1 = Get-GPO -Name "SoloBlocNotas"

    #Vincular la GPO a la UO "cuates"
    New-GPLink -Name $gpo1.DisplayName -Target $global:ouPathC -LinkEnabled Yes

    #Habilitar la política para permitir solo aplicaciones especificadas
    Set-GPRegistryValue -Name $gpo1.DisplayName -Key $global:regPath -ValueName "RunOnlyAllowed" -Type DWord -Value 1

    #Agregar el Bloc de Notas (notepad.exe) a la lista de aplicaciones permitidas
    Set-GPRegistryValue -Name $gpo1.DisplayName -Key $global:regPath -ValueName "AllowedApps" -Type MultiString -Value @("notepad.exe", "powershell.exe")

    #Crear la GPO "BloquearBlocNotas"
    $gpo2 = New-GPO -Name "BloquearBlocNotas"

    #Obtener la GPO creada
    $gpo2 = Get-GPO -Name "BloquearBlocNotas"

    #Vincular la GPO "BloquearBlocNotas" a la UO "cuates"
    Set-GPLink -Name $gpo2.DisplayName -Target $global:ouPathNC -LinkEnabled Yes

    #Habilitar la política para bloquear las aplicaciones especificadas
    Set-GPRegistryValue -Name $gpo2.DisplayName -Key $global:regPath -ValueName "DisallowRun" -Type DWord -Value 1

    #Especificar la lista de aplicaciones bloqueadas (solo el Bloc de Notas)
    Set-GPRegistryValue -Name $gpo2.DisplayName -Key $global:regPath -ValueName "DisallowedApps" -Type MultiString -Value @("notepad.exe")

    #Actualizar las políticas de grupo (aplicar cambios)
    gpupdate /force
}

function habilitar_auditorias(){
    auditpol /set /category:"Inicio/cierre de sesión" /success:enable /failure:enable
    auditpol /set /category:"Inicio de sesión de la cuenta" /success:enable /failure:enable

    auditpol /set /subcategory:"Acceso del servicio de directorio" /success:enable /failure:enable
    auditpol /set /subcategory:"Cambios de servicio de directorio" /success:enable /failure:enable

    auditpol /set /subcategory:"Administración de cuentas de usuario" /success:enable /failure:enable
    auditpol /set /subcategory:"Administración de cuentas de grupos de seguridad" /success:enable /failure:enable
    auditpol /set /subcategory:"Administración de cuentas de equipo" /success:enable /failure:enable
}

