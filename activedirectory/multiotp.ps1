# CONFIGURACIÓN INICIAL

# RUTAS Y URLS
$downloads = "$env:USERPROFILE\Downloads"

# multiOTP
$multiotpZipUrl = "https://github.com/multiOTP/multiotp/releases/download/5.9.5.1/multiotp_5.9.5.1.zip"
$multiotpZipName = "multiotp_5.9.5.1.zip"
$multiotpZipPath = Join-Path $downloads $multiotpZipName
$multiotpExtractPath = "$env:TEMP\multiotp_extract"
$multiotpFinalPath = "C:\multiotp"

# Visual C++
$vcRedistX86Url = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
$vcRedistX64Url = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcRedistX86Name = "vc_redist.x86.exe"
$vcRedistX64Name = "vc_redist.x64.exe"
$vcRedistX86Path = Join-Path $downloads $vcRedistX86Name
$vcRedistX64Path = Join-Path $downloads $vcRedistX64Name

# Verificar y descargar multiOTP
if (-Not (Test-Path $multiotpZipPath)) {
    Write-Host "Descargando multiOTP..."
    Invoke-WebRequest -Uri $multiotpZipUrl -OutFile $multiotpZipPath
} else {
    Write-Host "multiOTP ya está en Descargas"
}

# Verificar y descargar VC Redist x86
if (-Not (Test-Path $vcRedistX86Path)) {
    Write-Host "Descargando Visual C++ x86..."
    Invoke-WebRequest -Uri $vcRedistX86Url -OutFile $vcRedistX86Path
} else {
    Write-Host "vc_redist.x86.exe ya está en Descargas"
}

# Verificar y descargar VC Redist x64
if (-Not (Test-Path $vcRedistX64Path)) {
    Write-Host "Descargando Visual C++ x64..."
    Invoke-WebRequest -Uri $vcRedistX64Url -OutFile $vcRedistX64Path
} else {
    Write-Host "vc_redist.x64.exe ya está en Descargas"
}

# Extraer multiOTP
Write-Host "Extrayendo multiOTP..."
if (Test-Path $multiotpExtractPath) {
    Remove-Item $multiotpExtractPath -Recurse -Force
}
Expand-Archive -Path $multiotpZipPath -DestinationPath $multiotpExtractPath -Force

$sourceWindowsFolder = Join-Path $multiotpExtractPath "windows"

if (-Not (Test-Path $sourceWindowsFolder)) {
    Write-Host "Error: no se encontró la carpeta 'windows'"
    Get-ChildItem $multiotpExtractPath | Format-List FullName
    exit 1
}

# Limpiar C:\multiotp si ya existe
if (Test-Path $multiotpFinalPath) {
    Write-Host "Eliminando C:\multiotp anterior..."
    Remove-Item -Path $multiotpFinalPath -Recurse -Force
}

# Mover carpeta a C:\multiotp
Move-Item -Path $sourceWindowsFolder -Destination $multiotpFinalPath
Write-Host "multiOTP listo en C:\multiotp"

# Instalar Visual C++ Redistributables
Write-Host "Instalando Visual C++ Redistributables..."
Start-Process -FilePath $vcRedistX86Path -ArgumentList "/install", "/quiet", "/norestart" -Wait
Start-Process -FilePath $vcRedistX64Path -ArgumentList "/install", "/quiet", "/norestart" -Wait

# Ejecutar los instaladores de multiOTP
$radiusScript = Join-Path $multiotpFinalPath "radius_install.cmd"
$webserviceScript = Join-Path $multiotpFinalPath "webservice_install.cmd"

if (Test-Path $radiusScript) {
    Write-Host "Ejecutando radius_install.cmd..."
    Start-Process -FilePath $radiusScript -Verb RunAs -Wait
}

if (Test-Path $webserviceScript) {
    Write-Host "Ejecutando webservice_install.cmd..."
    Start-Process -FilePath $webserviceScript -Verb RunAs -Wait
}

Write-Host "Proceso finalizado"
