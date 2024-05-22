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
Write-Host "symlinks"
New-Item -Path $profile -ItemType SymbolicLink -Value powershell\profile\profile.ps1 -Force | Out-Null
New-Item -Path "$( Split-Path $profile)\imports" -ItemType SymbolicLink -Value powershell\profile\imports -Force | Out-Null
Get-ChildItem -Path "powershell\modules" | ForEach-Object -process {
    New-Item -Path "$($env:PSModulePath -split ';' | Select-Object -First 1)\$_" -ItemType SymbolicLink -Value "powershell\modules\$_" -Force | Out-Null
}
function Create-Symlinks {
    param(
        [string]$source,
        [string]$destination
    )
    Get-ChildItem $source | ForEach-Object -process {
        # $_ is a directory, create a symlink
        if((Test-Path "$source\$_" -PathType Container)){
            if(!(Test-Path "$destination\$_")){
                New-Item -Path "$destination\$_" -ItemType Directory -Force
            }
            if(!($_ -match "^\..*")){
                Create-Symlinks -source "$source\$_" -destination "$destination\$_"
            }else{
                $link = New-Item -Path "$destination\$_" -ItemType SymbolicLink -value "$source\$_" -Force
                $link.Attributes =  $link.Attributes -bor [System.IO.FileAttributes]::Hidden}
        }else{
            $link = New-Item -Path "$destination\$_" -ItemType SymbolicLink -value "$source\$_" -Force
            # if file name starts with ., it is a hidden file
            if($_ -match "^\..*"){
                $link.Attributes =  $link.Attributes -bor [System.IO.FileAttributes]::Hidden
            }
        }
    }
}

Create-Symlinks -source "home" -destination $HOME
Create-Symlinks -source "appdata" -destination $env:APPDATA
Create-Symlinks -source "appdata" -destination $env:LOCALAPPDATA
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Windows features..."
./setup/features.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Windows settings..."
./setup/settings.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Poweshell Modules..."
./setup/modules.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "Installing Software..."
./setup/software.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "configuring some additional Settings..."
./setup/additionalsettings.ps1
Write-Host -ForeGroundColor "Green" $("`rdone" + (" " * (([Console]::WindowWidth)-4)))
Write-Host "`n--all done--" -ForeGroundColor "Green"