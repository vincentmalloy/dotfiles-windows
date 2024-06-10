# Get the ID and security principal of the current user account
$myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myPrincipal = new-object System.Security.Principal.WindowsPrincipal($myIdentity)
# Check to see if we are currently running "as Administrator"
if ($myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "do not run this script with elevated privileges"
    exit
}

$dotfilesUser = Read-Host "Enter github username"

# install winget cli
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output "Installing winget"
    # install Microsoft.DesktopAppInstaller msixbundle from github
    $gitLatestReleaseApi = (Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/microsoft/winget-cli/releases/latest).Content | ConvertFrom-Json
    $wingetObject = $gitLatestReleaseApi.assets `
    | Where-Object { $_.name -match "Microsoft.DesktopAppInstaller_[a-zA-Z0-9]*?.msixbundle" } `
    | Select-Object browser_download_url | Select-Object -First 1
    Write-Host "downloading $($wingetObject.browser_download_url)"
    (New-Object Net.WebClient).DownloadFile($_.browser_download_url, "$env:temp\winget.msixbundle")
    Add-AppxPackage -Path "$env:temp\winget.msixbundle" -ForceApplicationShutdown
    # remove temp file
    Remove-Item -Path "$env:temp\winget.msixbundle" -Recurse -Force
    # refresh $path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
# install chocolatey
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey"
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    # refresh $path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    choco feature enable -n allowGlobalConfirmation
    choco feature enable -n=useEnhancedExitCodes
}
# install scoop
if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Scoop"
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
# install minimal git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Git.MinGit"
    winget install --source winget --id Git.MinGit --silent --accept-package-agreements
    # refresh $path
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    # make git trust windows cert
    git config --global http.sslBackend schannel
}

# clone dotfiles repo to $HOME folder
if (!(Test-Path "$HOME\.dotfiles")) {
    Write-Output "Cloning dotfiles repo to $HOME folder"
    git clone --recurse-submodules "https://github.com/$dotfilesUser/dotfiles-windows.git" "$HOME\.dotfiles"
    # hide .dotfiles folder
    $dotfilesFolder = Get-Item "$HOME\.dotfiles"
    $dotfilesFolder.Attributes = $dotfilesFolder.Attributes -bor [System.IO.FileAttributes]::Hidden
}else{
    # git clean and pull latest changes to .dotfiles folder
    Write-Output "Cleaning and pulling latest changes to .dotfiles folder"
    Push-Location "$HOME\.dotfiles"
    git clean -fd
    git pull
    Pop-Location
}

# run setup script in .dotfiles folder
Write-Output "Running setup script in .dotfiles folder"
Start-Process -Verb RunAs -FilePath powershell -ArgumentList "~/.dotfiles/setup.ps1" -Wait
