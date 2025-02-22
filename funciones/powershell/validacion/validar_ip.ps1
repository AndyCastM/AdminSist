function validar_ip {
    param ([string]$ip)

    $regex = "^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-4]|2[0-4][0-9]|1?[0-9][0-9]?))$"

    if ($ip -match $regex) {
        $ultimoOcteto = [int]($ip -split "\.")[3]
        return ($ultimoOcteto -ne 1 -and $ultimoOcteto -ne 255)
    }
    return $false
}
