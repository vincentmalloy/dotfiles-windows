
function Start-Awake {
    $wsh = New-Object -ComObject WScript.Shell
    $env:AWAKE="<f>$(Get-Emoji "e0ba")$(Get-Emoji "e0bc")$(Get-Emoji "2615")$(Get-Emoji "e0ba")$(Get-Emoji "e0bc")</f>"
    # Set-Environment "AWAKE" "<f>$(Get-Emoji "e0ba")$(Get-Emoji "e0bc")$(Get-Emoji "2615")$(Get-Emoji "e0ba")$(Get-Emoji "e0bc")</f>"
    if(-not(Get-Job -Name caffeine -ErrorAction SilentlyContinue)){
        Start-Job -Name caffeine -InputObject $wsh -ScriptBlock { 
            while (1) {
                $input.SendKeys('+{F15}')
                Start-Sleep -seconds 59
            }
        } | Out-Null
    }
}

function Stop-Awake{
    $env:AWAKE=""
    # Set-Environment "AWAKE" ""
    if((Get-Job -Name caffeine -ErrorAction SilentlyContinue)){
        Stop-Job -Name caffeine
        Remove-Job -Name caffeine
    }
}

Export-ModuleMember -Function Start-Awake
Export-ModuleMember -Function Stop-Awake