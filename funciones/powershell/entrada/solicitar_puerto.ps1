function solicitar_puerto {
    param ([string]$msg)

    $ports_restricted = @(21, 22, 23, 25, 53, 110, 143, 161, 162, 389, 443, 465, 993, 995, 1433, 1434, 1521, 3306, 3389,
                                          1, 7, 9, 11, 13, 15, 17, 19, 137, 138, 139, 2049, 3128, 6000)
    
    while ($true) {
        $port = Read-Host $msg

        # Verificar si el usuario ingresó un número válido
        if ($port -match '^\d+$') {
            $port = [int]$port

            # Validar rango permitido (evita puertos reservados)
            if ($port -lt 1024 -or $port -gt 65535) {
                Write-Host "El puerto debe estar entre 1024 y 65535." -ForegroundColor Red
                continue
            }

            # Verificar si el puerto está en uso
            if (netstat -an | Select-String ":$port " | Where-Object { $_ -match "LISTENING" }) {
                Write-Host "El puerto $port ya esta en uso. Intenta otro." -ForegroundColor Yellow
                continue
            }

            if ($port -in $ports_restricted){
                Write-Host "El puerto $port esta restringido. Intenta otro." -ForegroundColor Yellow
                continue
            }
            # Si pasa todas las validaciones, devolver el puerto
            return $port
        } else {
            Write-Host "Ingresa un numero valido." -ForegroundColor Red
        }
    }
}
