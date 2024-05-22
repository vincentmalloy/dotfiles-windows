$maxHeight = 25
function Show-Data($data, $positionX = 0, $positionY = 0) {
    $maxWidth = ($data | Measure-Object -Property length -Maximum).Maximum
    $verticalOffset = 0
    $data | ForEach-Object -process {
        if ($verticalOffset -lt $maxHeight) {
            [console]::setcursorposition($positionX - $maxWidth, $positionY + $verticalOffset)
            Write-Host "$($_.ToString().PadRight($maxWidth," "))"
            $verticalOffset++
        }
    }
    return
}

function Get-Art {
    $data = Get-Content "$PSScriptRoot\ascii-art.txt"
    return $data
}

function Get-Memos {
    $data = @(
        "$(Get-Emoji "1F4C3") Memos:"
        ""
    )
    $Memos = Get-MemoData
    if($Memos){
        $Memos | ForEach-Object -process {
            $data += "$($_.Time)  $($_.Text)"
        }
    }else{
        $data += "use [Add-Memo] to record a Memo"
    }
    
    return $data | Select-Object -Last ($maxHeight-2)
}

function Color-String($color, $string) {
    return "$("$([char]0x1b)[$($color)m")$string$("$([char]0x1b)[0m")"
}

function Get-Messages {
    $data = @(
        "$(Get-Emoji "1F44B") Hello $Env:UserName!"
        ""
        "Today is $((Get-Date).ToString((Get-Culture).DateTimeFormat.LongDatePattern))"
        ""
        "$(uptime)"
        ""
    )
    $data += "Free Disk Space:"
    $data += ""
    (Get-CimInstance -Class Win32_LogicalDisk | Select-Object -Property DeviceID, VolumeName, @{Label='FreeSpace (Gb)'; expression={($_.FreeSpace/1GB).ToString('F2')}},@{Label='Total (Gb)'; expression={($_.Size/1GB).ToString('F2')}},@{label='FreePercent'; expression={[Math]::Round(($_.freespace / $_.size) * 100, 2)}}) | ForEach-Object -process {
            $data += "$($_.VolumeName.PadRight(8," ")) ($($_.DeviceID)) $($_."FreeSpace (Gb)".PadLeft(8," ")) GB ($($_.FreePercent)%)"    
    }
    return $data
}


function Get-Warnings {
    $data = @(
        "$(Get-Emoji "26A0")  Warnings:"
        ""
    )
    if (Test-PendingReboot -SkipConfigurationManagerClientCheck | Select-Object -ExpandProperty IsRebootPending) {
        $data += "$(Get-Emoji "2757") There is a reboot pending, reboot as soon as possible!"
    }
    $psDrive = Get-PSDrive "C"
    $spaceTotal = $psDrive.Used + $psDrive.Free
    $percentageUsed = [math]::Round(($psDrive.Used / $spaceTotal)*100)
    if($percentageUsed -gt 85){
        $data += "$(Get-Emoji "2757") System Drive C: is almost Full! ($percentageUsed % - $($psDrive.Used) of $spaceTotal GB)"
    }
    if ($data.Length -le 2) {
        $data += "$(Get-Emoji "2705") All is well!"
    }
    return $data
}

function Show-Whale {
    $whale = Get-Art
    $whale += ""
    Clear-Host
    Show-Data $whale $Host.UI.RawUI.WindowSize.Width
}

function Show-Whalecome {
    Clear-Host
    $columns = 4
    if ($Host.UI.RawUI.WindowSize.Width -lt 200) {
        $columns = 3
    }
    if ($Host.UI.RawUI.WindowSize.Width -lt 120) {
        $columns = 2
    }
    $messagesData = Get-Messages
    $warningsData = Get-Warnings
    if ($columns -gt 2) {
        $memosData = Get-Memos
    }
    if ($columns -gt 3) {
        $artData = Get-Art
    }
    $dataLength = ($messagesData, $warningsData, $memosData, $artData | Measure-Object -Property length -Maximum).Maximum
    $offsetX = 0
    $messagesData, $warningsData, $memosData, $artData | ForEach-Object -process {
        if ($_) {
            $data = @()
            For ($i = 0; $i -lt $dataLength; $i++) {
                if ($i -lt $_.Length) {
                    $string = $_[$i].subString(0, [System.Math]::Min([System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columns), $_[$i].Length)) 
                    $data += $string
                }
                else {
                    $data += " "
                }
            }
            $width = ($data | Measure-Object -Property length -Maximum).Maximum
            Show-Data $data (([System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columns) * $offsetX) + $width)
            $offsetX++
        }
    }
    Write-Host $(" " * $Host.UI.RawUI.WindowSize.Width)
}

Export-ModuleMember -Function Show-Whalecome
Export-ModuleMember -Function Show-Whale