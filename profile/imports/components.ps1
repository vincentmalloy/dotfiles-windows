# oh-my-posh
if (Get-Command "oh-my-posh" -errorAction SilentlyContinue)
{
    oh-my-posh init pwsh --config "https://gist.githubusercontent.com/vincentmalloy/4b85151d28b3025451f5634b6081019d/raw/f40881c9a9381617c76d876f34f325f6be1010cc/omptheme.json" | Invoke-Expression
}
# psreadline
if(Get-InstalledModule -MinimumVersion  2.1.0 -Name PSReadLine){
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}
#gsudo
Import-Module 'gsudoModule'
Import-Module 'PowershellGet'
