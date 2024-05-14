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
New-Item -Path $profile -ItemType SymbolicLink -Value profile\profile.ps1 -Force | Out-Null
New-Item -Path "$( Split-Path $profile)\imports" -ItemType SymbolicLink -Value profile\imports -Force | Out-Null
function Create-Symlinks {
    param(
        [string]$source,
        [string]$destination
    )
    Get-ChildItem $source | ForEach-Object -process {
        # $_ is a directory, create a symlink
        if((Test-Path "$destination\$_" -PathType Container)){
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

Write-Host "done" -ForeGroundColor "Green"
Write-Host "Windows features..."
./setup/features.ps1
Write-Host "done" -ForeGroundColor "Green"
Write-Host "Windows settings..."
./setup/settings.ps1
Write-Host "done" -ForeGroundColor "Green"
Write-Host "Installing Software..."
./setup/software.ps1
Write-Host "done" -ForeGroundColor "Green"
Write-Host "configuring some additional Settings..."
./setup/additionalsettings.ps1
# ./setup/wallpaper.ps1 (Get-Item -Path ".\images\desktop\desktop_mid.jpg").FullName
Write-Host "`n--all done--" -ForeGroundColor "Green"