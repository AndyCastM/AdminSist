New-NetIpAddress -InterfaceAlias "Ethernet 2" -IPAddress 10.0.0.11 -PrefixLength 24 -DefaultGateway 10.0.0.1
Get-DnsClientServerAddress
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 10.0.0.12
Add-Computer -DomainName andycast.local -Credential andycast\Administrador -Restart
