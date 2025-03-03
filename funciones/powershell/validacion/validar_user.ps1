function validar_user {
    param (
        [string]$user,
        [int]$minLength = 5
    )

    $regex = '^[a-zA-Z][a-zA-Z0-9]*$'

    if ($user.Length -lt $minLength) {
        return $false
    }

    return $user -match $regex  
}