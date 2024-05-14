# powershell modules
if(!(Get-Module -ListAvailable PowerShellGet)){
    Write-Output "Installing PowerShellGet"
    Install-Module PowerShellGet -Force
}
if(!(Get-Module -ListAvailable -Name FP.SetWallpaper)){
    Write-Output "Installing FP.SetWallpaper"
    Install-Module -Name FP.SetWallpaper -Force
}
if(!(Get-InstalledModule -MinimumVersion  2.1.0 -Name PSReadLine)){
    Write-Output "Installing PSReadLine"
    Install-Module PSReadLine -MinimumVersion  2.1.0 -Force
}
# # remove microsoft store form winget sources
# # winget source remove msstore | Out-Null
# # install minimal git
# if(!(installed("Git.MinGit"))){
#     Write-Output "Installing Git.MinGit"
#     winget install --source winget --id Git.MinGit --silent --accept-package-agreements
# }
# # install keepassXC
# if(!(installed("KeePassXCTeam.KeePassXC"))){
#     Write-Output "Installing KeePassXCTeam.KeePassXC"
#     winget install --source winget --id KeePassXCTeam.KeePassXC --silent --accept-package-agreements
# }
# # install Microsoft.VisualStudioCode.Insiders
# if(!(installed("Microsoft.VisualStudioCode.Insiders"))){
#     Write-Output "Installing Microsoft.VisualStudioCode.Insiders"
#     winget install --source winget --id Microsoft.VisualStudioCode.Insiders --silent --accept-package-agreements
# }
# # install Nextcloud.NextcloudDesktop
# if(!(installed("Nextcloud.NextcloudDesktop"))){
#     Write-Output "Installing Nextcloud.NextcloudDesktop"
#     winget install --source winget --id Nextcloud.NextcloudDesktop --silent --accept-package-agreements
# }
# # install JanDeDobbeleer.OhMyPosh
# if(!(installed("JanDeDobbeleer.OhMyPosh"))){
#     Write-Output "Installing JanDeDobbeleer.OhMyPosh"
#     winget install --source winget --id JanDeDobbeleer.OhMyPosh --silent --accept-package-agreements
#     $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
#     oh-my-posh font install RobotoMono
# }
# # install MiKTeX.MiKTeX
# # if(!(installed("MiKTeX.MiKTeX"))){
# #     echo "Installing MiKTeX.MiKTeX"
# #     winget install --id MiKTeX.MiKTeX --silent --accept-package-agreements
# # }
# # install Mozilla.Firefox
# if(!(installed("Mozilla.Firefox"))){
#     Write-Output "Installing Mozilla.Firefox"
#     winget install --source winget --id Mozilla.Firefox --silent --accept-package-agreements
# }
# # install Helix.Helix
# if(!(installed("Helix.Helix"))){
#     Write-Output "Installing Helix.Helix"
#     winget install --source winget --id Helix.Helix --silent --accept-package-agreements
# }
# # install Microsoft.WindowsTerminal.Preview
# if(!(installed("Microsoft.WindowsTerminal.Preview"))){
#     Write-Output "Installing Microsoft.WindowsTerminal.Preview"
#     winget install --source winget --id Microsoft.WindowsTerminal.Preview --silent --accept-package-agreements
# }
# install Microsoft.OpenSSH.Beta
# if(!(installed("Microsoft.OpenSSH.Beta"))){
#     Write-Output "Installing Microsoft.OpenSSH.Beta"
#     winget install --source winget --id Microsoft.OpenSSH.Beta --silent --accept-package-agreements
# }