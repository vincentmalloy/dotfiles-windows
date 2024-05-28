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
    Install-Module PSWindowsUpdate -Force -AcceptLicense
}
if(!(Get-Module -ListAvailable -Name PSReadLine)){
    Write-Output "Installing PSReadLine"
    Install-Module PSReadLine -MinimumVersion  2.3.5 -Force
}
if(!(Get-Module -ListAvailable -Name Terminal-Icons)){
    Write-Output "installing Terminal-Icons"
    Install-Module -Name Terminal-Icons -Force -AcceptLicense -Repository PSGallery
}

Import-Module 'gsudoModule'
Import-Module 'PowershellGet'
Import-Module -Name Terminal-Icons
