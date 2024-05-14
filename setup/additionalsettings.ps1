# create gitconfig.local
$gitConfigLocalPath = "$env:USERPROFILE\.gitconfig.local"
if(!(Test-Path $gitConfigLocalPath)){
    Write-Host "Creating gitconfig.local..."
    # ask user for full name
    $gitName = Read-Host "Enter your full name"
    # ask user for email
    $gitEmail = Read-Host "Enter your email"
    # write to gitconfig.local
    @"
[user]
    email = $gitEmail
    name = $gitName
[init]
    templateDir = ~/.git_template
"@ | Out-File $gitConfigLocalPath -Encoding utf8
(Get-Item $gitConfigLocalPath).Attributes = (Get-Item $gitConfigLocalPath).Attributes -bor [System.IO.FileAttributes]::Hidden
}
# copy desktop images to pictures folder
$currentFolder = (Get-Item -Path ".\*\images\desktop").FullName
Write-Host "current folder: $currentFolder"
# setup vs code terminal font
Set-JsonData "$env:APPDATA\Code\User\settings.json" 'terminal.integrated.fontFamily' 'RobotoMono NFM'
# setup windows terminal settings
$settingsPath = (Get-Item "C:\users\$env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_*\LocalState\settings.json" | Select-Object -ExpandProperty FullName)
# get settings data
$settingsData = Get-Content -Raw -Path $settingsPath | ConvertFrom-Json
$settingsData.profiles.defaults.font.face = "RobotoMono Nerd Font Mono"
# write json data back to settings.json
$settingsData | ConvertTo-Json -Depth 10 | Out-File $settingsPath -Encoding utf8

# setup windows terminal font and background
# create shortcut for windows terminal quakemode in startup
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Windows Terminal Quake Mode.lnk"
if(!(Test-Path $shortcutPath)){
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
    $shortcut.WindowStyle = 7
    $shortcut.Arguments = "-w _quake"
    $shortcut.Save()
}