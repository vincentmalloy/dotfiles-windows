if(!(Get-Command winget -ErrorAction SilentlyContinue)){
  Write-Output "Installing winget"
  # install Microsoft.DesktopAppInstaller msixbundle from github
  $gitLatestReleaseApi = (Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/microsoft/winget-cli/releases/latest).Content | ConvertFrom-Json
  $wingetObject = $gitLatestReleaseApi.assets `
    | Where-Object {$_.name -match "Microsoft.DesktopAppInstaller_[\d.]*?.msixbundle"} `
    | Select-Object browser_download_url | Select-Object -First 1
  # download first asset
  $wingetObject `
    | ForEach-Object { Invoke-WebRequest -Uri $_.browser_download_url -UseBasicParsing -OutFile "$env:temp\winget.msixbundle" }
  # install msixbundle
  Add-AppxPackage -Path "$env:temp\winget.msixbundle" -ForceApplicationShutdown
  # remove temp file
  Remove-Item -Path "$env:temp\winget.msixbundle" -Recurse -Force
}
# remove microsoft store form winget sources
# winget source remove msstore | Out-Null
# install minimal git
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


# if(!(Get-Command git -ErrorAction SilentlyContinue)) {

#     $gitDir = "$env:LOCALAPPDATA\CustomGit"
#     if(Test-Path $gitDir) { Remove-Item -Path $gitDir -Recurse -Force }
#     New-Item -Path $gitDir -ItemType Directory
#     $gitLatestReleaseApi = (Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/git-for-windows/git/releases/latest).Content | ConvertFrom-Json
#     $mingitObject = $gitLatestReleaseApi.assets `
#       | Where-Object {$_.name -match "MinGit-[\d.]*?-64-bit.zip"} `
#       | Select-Object browser_download_url
  
#     Write-Host "Matching asset count: $((Measure-Object -InputObject $mingitObject).Count)"
  
#     if ((Measure-Object -InputObject $mingitObject).Count -eq 1) {
#       $mingitObject `
#         | ForEach-Object { Invoke-WebRequest -Uri $_.browser_download_url -UseBasicParsing -OutFile "$gitDir\mingit.zip" }
  
#       Write-Host "Installing latest release fetched from github api!"
#     } else {
#       Write-Host "There were more than one mingit assets found in the latest release!"
#       Write-Host "Installing release 2.26.2 instead!"
  
#       Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/MinGit-2.26.2-64-bit.zip" -UseBasicParsing -OutFile "$gitDir\mingit.zip"
#     }
  
#     Expand-Archive -Path "$gitDir\mingit.zip" -DestinationPath "$gitDir"
#     #Copy-Item -Path "$gitDir\mingit\cmd\git.exe" -Destination "$gitDir\git.exe" -Recurse
#     Remove-Item -Path "$gitDir\mingit.zip" -Recurse -Force
  
#     if(([Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)) -notlike "*$gitDir*") {
#       Write-Host "Updating PATH"
#       [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User) + ";$gitDir\cmd", [System.EnvironmentVariableTarget]::User)
#     }
#   }
# $packages = (
#   "Microsoft.WindowsTerminal.Preview"
#   "Git.MinGit"
#   "Mozilla.Firefox"
# )

# install chocolatey if not already installed
# i'f(!(Get-Command "choco")){
#     Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#     choco feature enable -n allowGlobalConfirmation
#     choco feature enable -n useEnhancedExitCodes
# }'
# # list of software to be installed
# $softwareList = (
#     "firefox",
#     "vlc",
#     # "vscode",
#     "steam",
#     "7zip",
#     "keepassxc",
#     "nextcloud-client",
#     "qbittorrent",
#     "vcredist-all",
#     "mkcert",
#     "microsoft-windows-terminal --pre",
#     "oh-my-posh",
#     "paint.net"
#     # miktex currently broken
#     # "miktex"
# )
# foreach($software in $softwareList){
#     # check if software is already installed
#     if(choco search $software --local-only --by-id-only --exact){
#         if($LASTEXITCODE -eq 2){
#             # no results, install software
#             choco install $software
#         }
#     }
# }