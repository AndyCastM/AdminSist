function dependencias{
    # Verificar e instalar Visual C++ Redistributable
    Write-Host "`nVerificando Visual C++ Redistributable..."

    $vcInstalled = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty | Where-Object { $_.DisplayName -match "Visual C\+\+ (2015|2017|2019|2022) Redistributable" }

    if ($vcInstalled) {
        Write-Host "Visual C++ Redistributable ya esta instalado."
    } else {
        Write-Host "Falta Visual C++. Descargando e instalando..."
        $vcUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
        $vcInstaller = "$env:TEMP\vc_redist.x64.exe"
        Invoke-WebRequest -Uri $vcUrl -OutFile $vcInstaller
        Start-Process -FilePath $vcInstaller -ArgumentList "/install /quiet /norestart" -NoNewWindow -Wait
        Write-Host "Visual C++ Redistributable instalado correctamente."
    }
}