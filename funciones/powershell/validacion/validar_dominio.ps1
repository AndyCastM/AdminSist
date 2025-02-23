function validar_dominio {
    param (
        [string]$dominio
    )

    $regex = '^(?:[a-zA-Z0-9-]{4,}\.)+(com|net|edu|blog|mx|tech|site)$'

    return $dominio -match $regex  
}