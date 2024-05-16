# powershell modules
if(!(Get-Module -ListAvailable PowerShellGet)){
    Write-Output "Installing PowerShellGet"
    Install-Module PowerShellGet -Force
}
if(!(Get-Module -ListAvailable -Name FP.SetWallpaper)){
    Write-Output "Installing FP.SetWallpaper"
    Install-Module -Name FP.SetWallpaper -Force -AcceptLicense
}
if(!(Get-Module -ListAvailable -Name PSWindowsUpdate)){
    Write-Output "Installing PSWindowsUpdate"
    Install-Module PSWindowsUpdate -Scope CurrentUser -Force
}
if(!(Get-InstalledModule -MinimumVersion  2.1.0 -Name PSReadLine)){
    Write-Output "Installing PSReadLine"
    Install-Module PSReadLine -MinimumVersion  2.1.0 -Force
}