function fijar_ip {
    param ([string]$ip, [string]$interface)
    New-NetIPAddress -IPAddress $ip -InterfaceAlias $interface -PrefixLength 24
}
