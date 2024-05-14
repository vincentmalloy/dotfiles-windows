Write-Host "Setting up dotfiles..."
# Get the ID and security principal of the current user account
$myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)
# Check to see if we are currently running "as Administrator"
if(!$myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Host "please run this script in a Powershell with elevated Privileges"
    Read-Host "Press any key to exit"
    exit
}
Write-Host "symlinks"
New-Item -Path $profile -ItemType SymbolicLink -Value profile\profile.ps1 -Force
New-Item -Path "$( Split-Path $profile)\imports" -ItemType SymbolicLink -Value profile\imports -Force
Get-ChildItem home -name | ForEach-Object -process {
    $link = New-Item -Path "$HOME\$_" -ItemType SymbolicLink -value "home\$_" -Force
    # if file name starts with ., it is a hidden file
    if($_ -match "^\..*"){
        $link.Attributes =  $link.Attributes -bor [System.IO.FileAttributes]::Hidden
    }
}
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
Write-Host "--all done--" -ForeGroundColor "Green"
Read-Host "Press any key to exit"