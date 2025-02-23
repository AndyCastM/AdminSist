Get-Service -Name sshd
Start-Service -Name sshd
Set-Service -Name sshd -StartupType Automatic
New-NetFirewallRule -Name "SSH" -DisplayName "SSH" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22