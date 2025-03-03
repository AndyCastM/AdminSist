function UsuarioExiste {
    param (
        [string]$Usuario
    )

    $usuarioADSI = [ADSI]"WinNT://$env:ComputerName/$Usuario,user"
    
    if ($usuarioADSI.Path) {
        return $true
    } else {
        Write-Host "El usuario '$Usuario' NO existe en el sistema." -ForegroundColor Red
        return $false
    }
}
