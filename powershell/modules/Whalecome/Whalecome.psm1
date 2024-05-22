$maxHeight=30
$columns=4
function Show-Data($data,$positionX=0,$positionY=0)
{
    $maxWidth = ($data | Measure-Object -Property length -Maximum).Maximum
    $verticalOffset = 0
    $data | ForEach-Object -process {
        if($verticalOffset -lt $maxHeight){
            [console]::setcursorposition($positionX-$maxWidth, $positionY + $verticalOffset)
            Write-Host "$($_.ToString().PadRight($maxWidth," "))"
            $verticalOffset++
        }
    }
    return
}

function Get-Art
{
    $data=Get-Content "$PSScriptRoot\ascii-art.txt"
    return $data+=""
}

function Get-Memos
{
    $Path = "~/Memos.csv"
    if(Test-Path $Path -pathType leaf){
        $Memos = Import-Csv -Path $Path | Select-Object Time, Text
    }else{
        return
    }
    $data = @(
        "$(Get-Emoji "1F4C3") Memos:"
    )
    $Memos | ForEach-Object -process {
        $data += "$($_.Time)  $($_.Text)"
    }

	return $data
}

function Color-String($color,$string)
{
    return "$("$([char]0x1b)[$($color)m")$string$("$([char]0x1b)[0m")"
}

function Get-Messages
{
    $data = @(
        "$(Get-Emoji "1F44B") Hello $Env:UserName!"
        # "Hello $Env:UserName!"
        "$(uptime)"
    )
    return $data
}

function Get-Warnings
{
    $data=@(
        "$(Get-Emoji "26A0")  Warnings:"
    )
    if(Test-PendingReboot -SkipConfigurationManagerClientCheck | Select -ExpandProperty IsRebootPending){
        $data += "$(Get-Emoji "2757") There is a reboot pending, reboot as soon as possible!"
    }
    if($data.Length -le 1){
        $data += "$(Get-Emoji "2705") All is well!"
    }
    return $data
}

function Show-Whalecome
{
    $messagesData = Get-Messages
    $warningsData = Get-Warnings
    $memosData = Get-Memos
    $artData = Get-Art
    $dataLength = ($messagesData, $warningsData, $memosData, $artData | Measure-Object -Property length -Maximum).Maximum
    $offsetX = 0
    $messagesData, $warningsData, $memosData, $artData | ForEach-Object -process {
        $data=@()
        For ($i = 0;$i -lt $dataLength;$i++)
        {
            if($i -lt $_.Length){
                $string = $_[$i].subString(0, [System.Math]::Min([System.Math]::Floor($Host.UI.RawUI.WindowSize.Width/$columns), $_[$i].Length)) 
                $data+=$string
            }else{
                $data+=" "
            }
        }
        $width=($data | Measure-Object -Property length -Maximum).Maximum
        Show-Data $data (([System.Math]::Floor($Host.UI.RawUI.WindowSize.Width/$columns)*$offsetX)+$width)
        $offsetX++
    }
}

Export-ModuleMember -Function Show-Whalecome