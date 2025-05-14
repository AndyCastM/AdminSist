# Función para auditoría general de AD
function Get-ADEvents {
    [CmdletBinding()]
    param ()

    # Event IDs clave para AD 
    $targetEvents = @(4662, 4738, 4720, 4726, 4767)

    try {
        $events = Get-WinEvent -LogName Security -FilterXPath "*[System[EventID=$($targetEvents -join ' or EventID=')]]" -MaxEvents 1000 -ErrorAction Stop

        $report = $events | ForEach-Object {
            [PSCustomObject]@{
                Fecha      = $_.TimeCreated
                EventoID   = $_.Id
                Accion     = switch ($_.Id) {
                    4662 { "Acceso a objeto AD" }
                    4738 { "Cambio en grupo (membresia)" }
                    4720 { "Usuario creado" }
                    4726 { "Usuario eliminado" }
                    4767 { "Cambio en cuenta de servicio" }
                    default { "Otro" }
                }
                Usuario    = $_.Properties[5].Value
                Objetivo   = $_.Properties[4].Value
            }
        }

        $report | Sort-Object Fecha -Descending -Unique | Format-Table -AutoSize
    }
    catch {
        Write-Host "Error al leer eventos: $_" -ForegroundColor Red
    }
}