# Create Workdir
$BasePath = "C:\Windows\Temp\Install"
New-item $BasePath -itemtype directory


# Add RedHat to Trusted Publisher
$CertName = "balloon.cer"
$ExportCert = Join-Path $BasePath -ChildPath $CertName

$Cert = (Get-AuthenticodeSignature "e:\Balloon\2k19\amd64\balloon.sys").SignerCertificate
$ExportType = [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert

[System.IO.File]::WriteAllBytes($ExportCert, $Cert.Export($ExportType))
Import-Certificate -FilePath $ExportCert -CertStoreLocation Cert:\LocalMachine\TrustedPublisher

# install Guest Agent
msiexec /i e:\virtio-win-gt-x64.msi /qn /passive

# install Qemu Tools (Drivers)
msiexec /i e:\guest-agent\qemu-ga-x86_64.msi /qn /passive


# Get Cloud-init
Set-ExecutionPolicy Unrestricted
$Cloudinit = "CloudbaseInitSetup_Stable_x64.msi"
$CloutinitLocaion =  Join-Path -Path "C:\windows\temp\" -ChildPath $Cloudinit
invoke-webrequest https://www.cloudbase.it/downloads/$Cloudinit -o $CloutinitLocaion

cmd /C start /wait msiexec /i $CloutinitLocaion /qn

# Cleanup
Remove-item $BasePath -Recurse

# Remove AutoLogin
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f

# Run Sysprep and Shutdown
cmd /C 'cd "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\" && C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:Unattend.xml'
