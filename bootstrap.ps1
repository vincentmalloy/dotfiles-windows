# Get the ID and security principal of the current user account
$myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myPrincipal = new-object System.Security.Principal.WindowsPrincipal($myIdentity)
# Check to see if we are currently running "as Administrator"
if ($myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "do not run this script with elevated privileges"
    exit
}
$dotfilesUser = Read-Host "Enter github username"

$prerequisiteInstallation = {
    # install winget cli
    if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Output "Installing winget"
        # install Microsoft.DesktopAppInstaller msixbundle from github
        $gitLatestReleaseApi = (Invoke-WebRequest -UseBasicParsing https://api.github.com/repos/microsoft/winget-cli/releases/latest).Content | ConvertFrom-Json
        $wingetObject = $gitLatestReleaseApi.assets `
        | Where-Object { $_.name -match "Microsoft.DesktopAppInstaller_[\d.]*?.msixbundle" } `
        | Select-Object browser_download_url | Select-Object -First 1
        # download first asset
        $wingetObject `
        | ForEach-Object { (New-Object Net.WebClient).DownloadFile($_.browser_download_url, "$env:temp\winget.msixbundle") }
        # install msixbundle
        Add-AppxPackage -Path "$env:temp\winget.msixbundle" -ForceApplicationShutdown
        # remove temp file
        Remove-Item -Path "$env:temp\winget.msixbundle" -Recurse -Force
    }
    # install minimal git
    function installed($id) {
        winget list --source winget -q $id | Out-Null
        if ($?) { return $true } else { return $false }
    }

    if (!(installed("Git.MinGit"))) {
        Write-Output "Installing Git.MinGit"
        winget install --source winget --id Git.MinGit --silent --accept-package-agreements
    }
}

Start-Process -Verb RunAs -FilePath "powershell" -ArgumentList "-NoProfile -Command $prerequisiteInstallation" -Wait

# clone dotfiles repo to $HOME folder
if (!(Test-Path "$HOME\.dotfiles")) {
    Write-Output "Cloning dotfiles repo to $HOME folder"
    git clone "https://github.com/$dotfilesUser/dotfiles-windows.git" "$HOME\.dotfiles"
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