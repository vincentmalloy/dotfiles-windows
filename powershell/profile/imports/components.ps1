# oh-my-posh
if (Get-Command "oh-my-posh" -errorAction SilentlyContinue)
{
    oh-my-posh init pwsh --config "$env:USERPROFILE\.dotfiles\omptheme\omptheme.json" | Invoke-Expression
}
# check psreadline version (get-command is faster than get-installedmodule)
if((Get-Command PSConsoleHostReadLines -errorAction SilentlyContinue | Select -ExpandProperty "Version" | Select -ExpandProperty "Major") -ge 2){
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}
if(Get-Module -ListAvailable -Name Terminal-Icons){
    Import-Module -Name Terminal-Icons
}