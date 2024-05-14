# create gitconfig.local
$gitConfigLocalPath = "$env:USERPROFILE\.gitconfig.local"
if (!(Test-Path $gitConfigLocalPath)) {
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
# create .gitignore_global if it does not exist
if (!(Test-Path "$env:USERPROFILE\.gitignore_global")) {
    Write-Host "Creating .gitignore_global..."
    (New-Object Net.WebClient).DownloadFile("https://www.gitignore.io/api/windows,visualstudio,visualstudiocode", "$env:USERPROFILE\.gitignore_global")
    $gitIgnore = Get-Item "$env:USERPROFILE\.gitignore_global"
    $gitIgnore.Attributes =  $gitIgnore.Attributes -bor [System.IO.FileAttributes]::Hidden
}
# setup wallpaper
$monitors = Get-Monitor
if ($monitors.Length -eq 3) {
    $monitors | Select-Object -Index 0 | Set-Wallpaper -Path (Get-Item -Path ".\images\desktop\desktop_left.jpg").FullName
    $monitors | Select-Object -Index 1 | Set-Wallpaper -Path (Get-Item -Path ".\images\desktop\desktop_right.jpg").FullName
    $monitors | Select-Object -Index 2 | Set-Wallpaper -Path (Get-Item -Path ".\images\desktop\desktop_mid.jpg").FullName
}
else {
    Set-Wallpaper -Path (Get-Item -Path ".\images\desktop\desktop_mid.jpg").FullName
}
# setup vs code terminal font
$vsCodeSettingsPath = (Get-Item "$env:APPDATA\Code*\User\settings.json" | Select-Object -ExpandProperty FullName)
$vsCodeSettingsData = Get-Content -Raw -Path $vsCodeSettingsPath | ConvertFrom-Json
$vsCodeSettingsData | Add-Member -Name "terminal.integrated.fontFamily" -Value "RobotoMono NFM" -MemberType NoteProperty -Force
$vsCodeSettingsData | ConvertTo-Json | Out-File $vsCodeSettingsPath -Encoding utf8

# setup windows terminal settings
$settingsPath = (Get-Item "C:\users\$env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_*\LocalState\settings.json" | Select-Object -ExpandProperty FullName)
# get settings data
$settingsData = Get-Content -Raw -Path $settingsPath | ConvertFrom-Json
# set font face
if(!(Get-Member -InputObject $settingsData -Name "profiles")){
    $settingsData | Add-Member -Name "profiles" -Value @{} -MemberType NoteProperty
}
if(!(Get-Member -InputObject $settingsData.profiles -Name "defaults")){
    $settingsData.profiles | Add-Member -Name "defaults" -Value @{} -MemberType NoteProperty
}
if(!(Get-Member -InputObject $settingsData.profiles.defaults -Name "font")){
    $settingsData.profiles.defaults | Add-Member -Name "font" -Value @{} -MemberType NoteProperty
}
if(!(Get-Member -InputObject $settingsData.profiles.defaults.font -Name "face")){
    $settingsData.profiles.defaults.font | Add-Member -Name "face" -Value "Cascadia Mono" -MemberType NoteProperty
}
$settingsData.profiles.defaults.font.face = "RobotoMono Nerd Font Mono"
# set background image
if(!(Get-Member -InputObject $settingsData.profiles.defaults -Name "backgroundImage")){
    $settingsData.profiles.defaults | Add-Member -Name "backgroundImage" -Value @{} -MemberType NoteProperty
}
$settingsData.profiles.defaults.backgroundImage = (Get-Item -Path ".\images\terminal_bg.jpg").FullName
# write json data back to settings.json
$settingsData | ConvertTo-Json -Depth 10 | Out-File $settingsPath -Encoding utf8

# create shortcut for windows terminal quakemode in startup
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Windows Terminal Quake Mode.lnk"
if (!(Test-Path $shortcutPath)) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
    $shortcut.WindowStyle = 7
    $shortcut.Arguments = "-w _quake"
    $shortcut.Save()
}
