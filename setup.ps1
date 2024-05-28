Write-Host "Setting up dotfiles...`n"
Set-Location $HOME\.dotfiles
# Get the ID and security principal of the current user account
$myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)
# Check to see if we are currently running "as Administrator"
if(!$myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Host "please run this script in a Powershell with elevated Privileges"
    Read-Host "Press [Return] key to exit"
    exit
}

Write-Host "Powershell Profile"
# symlink profile
New-Item -Path $profile -ItemType SymbolicLink -Value "$env:USERPROFILE\.dotfiles\powershell\profile\profile.ps1" -Force | Out-Null
New-Item -Path "$( Split-Path $profile)\imports" -ItemType SymbolicLink -Value "$env:USERPROFILE\.dotfiles\powershell\profile\imports" -Force | Out-Null
# setup custom modules
$modulePath = ($env:PSModulePath -split ';' | Select-Object -First 1)
# cleanup module symlinks
Get-ChildItem -Path $modulePath | ForEach-Object -process {
    if(!(Get-ChildItem -Path "$modulePath\$($_.Name)" -ErrorAction SilentlyContinue)){
        Remove-Item $_.FullName
    }
}
# symlink modules
Get-ChildItem -Path ".\powershell\modules" | ForEach-Object -process {
    New-Item -Path "$modulePath\$($_.Name)" -ItemType SymbolicLink -Value $_.FullName -Force | Out-Null
}
# import modules
Get-ChildItem -Path ".\powershell\modules" | ForEach-Object -process {
    Import-Module $_.Name
}

Write-Host "misc. symlinks"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.gitconfig" -Value "$env:USERPROFILE\.dotfiles\home\.gitconfig" -Force | Out-Null
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.git_template" -Value "$env:USERPROFILE\.dotfiles\home\.git_template" -Force | Out-Null
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\helix\config.toml" -Value "$env:USERPROFILE\.dotfiles\home\APPDATA\helix\config.toml" -Force | Out-Null
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\wslconfig" -Value "$env:USERPROFILE\.dotfiles\home\wslconfig" -Force | Out-Null
$filePath = "powershell.exe"
if($PSVersionTable.PsVersion.Major -eq 7){
    $filePath = "pwsh.exe"
}
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Windows features..."
Start-Process -Verb RunAs -FilePath $filePath -ArgumentList "$env:USERPROFILE/.dotfiles/setup/features.ps1" -Wait
# ./setup/features.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Windows settings..."
Start-Process -Verb RunAs -FilePath $filePath -ArgumentList "$env:USERPROFILE/.dotfiles/setup/settings.ps1" -Wait
# ./setup/settings.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Powershell Modules..."
Start-Process -Verb RunAs -FilePath $filePath -ArgumentList "$env:USERPROFILE/.dotfiles/setup/modules.ps1" -Wait
# ./setup/modules.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Installing Software..."
Start-Process -Verb RunAs -FilePath $filePath -ArgumentList "$env:USERPROFILE/.dotfiles/setup/software.ps1" -Wait
# ./setup/software.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "configuring some additional Settings..."
Start-Process -Verb RunAs -FilePath $filePath -ArgumentList "$env:USERPROFILE/.dotfiles/setup/additionalsettings.ps1" -Wait
# ./setup/additionalsettings.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "`n--all done--" -ForeGroundColor "Green"