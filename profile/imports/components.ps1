# oh-my-posh
if (Get-Command "oh-my-posh" -errorAction SilentlyContinue)
{
    oh-my-posh init pwsh --config "https://raw.githubusercontent.com/vincentmalloy/dotfiles/main/omptheme.json" | Invoke-Expression
}