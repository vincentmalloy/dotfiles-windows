# oh-my-posh
if (Get-Command "oh-my-posh" -errorAction SilentlyContinue)
{
    oh-my-posh init pwsh --config "$env:USERPROFILE\.dotfiles\omptheme\omptheme.json" | Invoke-Expression
}
# psreadline
if(Get-InstalledModule -MinimumVersion  2.1.0 -Name PSReadLine){
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}
#gsudo
Import-Module 'gsudoModule'
Import-Module 'PowershellGet'
