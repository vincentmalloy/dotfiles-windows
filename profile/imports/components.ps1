# oh-my-posh
if (Get-Command "oh-my-posh" -errorAction SilentlyContinue)
{
    oh-my-posh init pwsh --config "https://gist.githubusercontent.com/vincentmalloy/4b85151d28b3025451f5634b6081019d/raw/295f7b3ca39075ac69955c2a08a8ef24a6965f72/omptheme.json" | Invoke-Expression
}
# psreadline
if(Get-InstalledModule -MinimumVersion  2.1.0 -Name PSReadLine){
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}
#gsudo
Import-Module 'gsudoModule'
Import-Module 'PowershellGet'
