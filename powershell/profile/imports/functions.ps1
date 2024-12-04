# Basic commands
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }
function touch($file) { "" | Out-File $file -Encoding ASCII }

# Common Editing needs
function Edit-Hosts { Invoke-Expression "sudo $(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $env:windir\system32\drivers\etc\hosts" }
function Edit-Profile { Invoke-Expression "$(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $profile" }
function Edit-Dotfiles { Invoke-Expression "$(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $env:USERPROFILE\.dotfiles" }

# refresh path
function refreshPath() {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# winget query if package is installed
function installed($id) {
    winget list --source winget -q $id | Out-Null
    if ($?) { return $true } else { return $false }
}
# System Update - Update Windows and installed software
function Update-System() {
    $isAdmin = $false
    $myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal = new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    if ($myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $isAdmin = $true
    }
    Write-Host "checking for windows updates..."
    if ($isAdmin) {
        Get-WindowsUpdate -Install -IgnoreUserInput -IgnoreReboot -AcceptAll
    }
    else {
        sudo Get-WindowsUpdate -Install -IgnoreUserInput -IgnoreReboot -AcceptAll
    }
    Write-Host "updating WSL"
    if ($ifAdmin) {
        wsl --update
    }
    else {
        sudo wsl --update
    }
    Write-Host "done" -ForegroundColor Green
    Write-Host "checking for software updates..."
    winget update --all -s winget
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco outdated | out-null
        if($LASTEXITCODE -eq 2){
            if ($isAdmin) {
                choco upgrade all
            }
            else {
                sudo choco upgrade all
            }
        }
    }
    Write-Host "done" -ForegroundColor Green
    Write-Host "not yet updating nixos..."
    Write-Host "all done!" -ForegroundColor Green
    if (Test-PendingReboot) {
        Write-Host "There is a reboot pending, reboot as soon as possible!" -ForegroundColor Red
    }
}
function Is-NetworkAvailable() {
    $networkavailable = $false;
    foreach ($adapter in Get-NetAdapter) {
        if ($adapter.status -eq "Up") { $networkavailable = $true; break; }
    }
    return $networkavailable
}
#set values in a json file
function Set-JsonData {
    param (
        $path,
        $setting,
        $value
    )
    
    $data = Get-Content -Raw -Path $path -ErrorAction silentlycontinue | ConvertFrom-Json
    if ($data) {
        if ($data.$setting) {
            $data.PSObject.Properties.Remove($setting)
        }
        $data | Add-Member -Name $setting -Value "$value" -MemberType NoteProperty
    }
    $data | ConvertTo-Json | Out-File $path -Encoding utf8
}

Function Get-PublicIP {
 (Invoke-WebRequest http://ifconfig.me/ip ).Content
}