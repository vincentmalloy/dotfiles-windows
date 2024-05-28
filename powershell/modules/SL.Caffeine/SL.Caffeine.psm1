
function Start-Awake {
    Set-Environment "AWAKE" "<f>$(ConvertFrom-Utf16Hex "e0ba")$(ConvertFrom-Utf16Hex "e0bc")$(Get-Emoji "Coffee")$(ConvertFrom-Utf16Hex "e0ba")$(ConvertFrom-Utf16Hex "e0bc")</f>"
    if(-not(Get-Job -Name caffeine -ErrorAction SilentlyContinue)){
        Start-Job -Name caffeine -ScriptBlock {
            $wsh = New-Object -ComObject WScript.Shell
            while (1) {
                $wsh.SendKeys('+{F15}')
                Start-Sleep -seconds 59
            }
        } | Out-Null
    }
}

function Stop-Awake{
    $env:AWAKE=""
    Set-Environment "AWAKE" ""
    if((Get-Job -Name caffeine -ErrorAction SilentlyContinue)){
        Stop-Job -Name caffeine
        Remove-Job -Name caffeine
    }
}

Export-ModuleMember -Function Start-Awake
Export-ModuleMember -Function Stop-Awake