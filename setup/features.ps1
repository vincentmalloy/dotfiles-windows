# add media feature pack (video playback will not work in firefox otherwise)
if($(Get-WindowsCapability -online | Where-Object -Property name -like "Media.MediaFeaturePack*" | Select-Object -ExpandProperty "State") -ne "Installed"){
    Get-WindowsCapability -online | Where-Object -Property name -like "Media.MediaFeaturePack*" | Add-WindowsCapability -Online
}
# add dependencies
# if(!(Get-AppxPackage | Where-Object -Property name -like "Microsoft.VCLibs.14*")){
#     Add-AppxPackage .\setup\dependencies\Microsoft.VCLibs.x64.14.00.Desktop.appx
# }
# install wsl
if(!(wsl -l)){
    wsl --set-default-version 2
    wsl --install
    wsl --set-default-version 2
}
