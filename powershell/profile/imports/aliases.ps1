# Easier Navigation: .., ..., ...., ....., and ~
${function:~} = { Set-Location ~ }
# PoSh won't allow ${function:..} because of an invalid path error, so...
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

${function:ll} = { Get-ChildItem -Force }

# Navigation Shortcuts
${function:cloud} = { Set-Location ~\Nextcloud }
${function:dt} = { Set-Location ~\Desktop }
${function:docs} = { Set-Location ~\Documents }
${function:dl} = { Set-Location ~\Downloads }
${function:df} = { Set-Location ~\.dotfiles }

# git alias function (without parameters it acts as git status)
${function:g} = { if ($args) { & git $args } else { & git status -sb} }
${function:ga} = { & git add $args }
${function:gg} = { if ($args) { & git add .;git commit -m $args;git push} else { & git add .;git commit -m "update";git push } }
${function:hush} = { if ($args) { & psshutdown -d -t $args | Out-Null} else { & psshutdown -d -t 0 | Out-Null} }

# Missing Bash aliases
Set-Alias time Measure-Command

# misc
Set-Alias l Get-ChildItem
Set-Alias c Clear-Host
Set-Alias u ubuntu
Set-Alias e explorer
Set-Alias terminate Stop-Computer
Set-Alias reboot Restart-Computer

New-Alias -Name 'Awake' -Value 'Start-Awake' -Scope Global -Force
New-Alias -Name 'Asleep' -Value 'Stop-Awake' -Scope Global -Force