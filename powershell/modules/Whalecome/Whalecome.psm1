$maxHeight = 25
$updateOKChar = "$([System.Char]::ConvertFromUtf32([System.Convert]::toInt32("2705", 16)))"
$updateWarnChar = "$([System.Char]::ConvertFromUtf32([System.Convert]::toInt32("2757", 16)))"

function Show-Data($data, $positionX = 0, $positionY = 0) {
    $maxWidth = ($data | Measure-Object -Property length -Maximum).Maximum
    $verticalOffset = 0
    $data | ForEach-Object -process {
        if ($verticalOffset -lt $maxHeight) {
            [console]::setcursorposition($positionX - $maxWidth, $positionY + $verticalOffset)
            $color = "White"
            if($_){
                if($_.substring(0, 1) -eq $updateWarnChar){
                    $color = "Yellow"
                }
            }
            Write-Host "$($_.ToString().PadRight($maxWidth," "))" -ForegroundColor $color
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
    if ($Memos) {
        $Memos | ForEach-Object -process {
            $data += "$($_.Time)  $($_.Text)"
        }
    }
    else {
        $data += "use [Add-Memo] to record a Memo"
    }
    
    return $data | Select-Object -Last ($maxHeight - 2)
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
    (Get-CimInstance -Class Win32_LogicalDisk | Select-Object -Property DeviceID, VolumeName, @{Label = 'FreeSpace (Gb)'; expression = { ($_.FreeSpace / 1GB).ToString('F2') } }, @{Label = 'Total (Gb)'; expression = { ($_.Size / 1GB).ToString('F2') } }, @{label = 'FreePercent'; expression = { [Math]::Round(($_.freespace / $_.size) * 100, 2) } }) | ForEach-Object -process {
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
        $data += "$updateWarnChar System Reboot Pending"
    }
    $psDrive = Get-PSDrive "C"
    $spaceTotal = $psDrive.Used + $psDrive.Free
    $percentageUsed = [math]::Round(($psDrive.Used / $spaceTotal) * 100)
    if ($percentageUsed -gt 85) {
        $data += "$updateWarnChar System Drive C: is almost Full! ($percentageUsed % - $([System.Math]::Floor($psDrive.Used/1GB)) of $([System.Math]::Floor($spaceTotal/1GB)) GB)"
    }

    return $data
}

function Show-Whale {
    $whale = Get-Art
    $whale += ""
    Clear-Host
    Show-Data $whale $Host.UI.RawUI.WindowSize.Width
}

function Write-Updates($columns, $verticalOffset) {
    $Global:c = $columns
    $Global:v = $verticalOffset
    $Global:updateChars = New-Object PSObject -Property @{
        updateWarnChar = $updateWarnChar
        updateOkChar   = $updateOkChar
    }
    $scriptBlock = {
        function Get-Emoji($hex) {
            $EmojiIcon = [System.Convert]::toInt32($hex, 16)
            return [System.Char]::ConvertFromUtf32($EmojiIcon)
        }
        $returnValue = @()
        if (sudo Get-WindowsUpdate -NotCategory "Drivers") {
            $returnValue += "$(Get-Emoji "2757") Windows: updates available"
        }
        else {
            $returnValue += "$(Get-Emoji "2705") Windows: no updates to install"
        }
        $softwareUpgrades = winget upgrade | Select-Object -Last 1
        if (-not($softwareUpgrades.subString(0,2) -eq "No")) {
            $returnValue += "$(Get-Emoji "2757") winget: $softwareUpgrades"
        }
        else {
            $returnValue += "$(Get-Emoji "2705") winget: no upgrades to install"
        }
        return $returnValue
    }
    $job = Start-Job -Name updates -ScriptBlock $scriptBlock
    $null = Register-ObjectEvent -InputObject $job -EventName StateChanged -MessageData $job.Id -SourceIdentifier updates.monitor -Action {
        $Global:updatesEvent = $event
        $cursor = New-Object PSObject -Property @{
            Top  = [console]::CursorTop
            Left = [console]::CursorLeft
        }
        Receive-Job $updatesEvent.sender.id | ForEach-Object -process {
            [console]::setcursorposition(([System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $c) * 1), $v)
            $color = "White"
            if ($_.substring(0, 1) -eq $updateChars.updateWarnChar) {
                $color = "Yellow"
            }
            Write-Host "$_" -ForegroundColor $color
            $v++
        }
        [console]::setcursorposition($cursor.Left, $cursor.Top)
        Stop-Job -Name "updates"
        Remove-Job -Name "updates"
        Unregister-Event $updatesEvent
        Remove-Event $updatesEvent
        Stop-Job -Name "updates.monitor"
        Remove-Job -Name "updates.monitor"
        Remove-Variable $updatesEvent
        Remove-Variable $c
        Remove-Variable $v
    }
}

function Write-Weather([string]$location = "idar-oberstein") {
    $jobInput = New-Object PSObject -Property @{
        location = $location
    }
    $scriptBlock = {
        invoke-RestMethod "https://wttr.in/$($input.location)?0QF" | Write-Output
    }
    $job = Start-Job -Name wttr -InputObject $jobInput -ScriptBlock $scriptBlock
    $null = Register-ObjectEvent -InputObject $job -EventName StateChanged -MessageData $job.Id -SourceIdentifier wttr.monitor -Action {
        $Global:wttrEvent = $event
        $verticalOffset = 10
        $result = Receive-Job $wttrEvent.sender.id
        $lines = $result.Split([Environment]::NewLine)
        $cursor = New-Object PSObject -Property @{
            Top  = [console]::CursorTop
            Left = [console]::CursorLeft
        }
        $lines | ForEach-Object -process {
            [console]::setcursorposition($Host.UI.RawUI.WindowSize.Width - 50, 0 + $verticalOffset)
            Write-Host "$_" -NoNewLine
            $verticalOffset++
        }
        [console]::setcursorposition($cursor.Left, $cursor.Top)
        Stop-Job -Name "wttr"
        Remove-Job -Name "wttr"
        Unregister-Event $wttrEvent
        Remove-Event $wttrEvent
        Stop-Job -Name "wttr.monitor"
        Remove-Job -Name "wttr.monitor"
        Remove-Variable $wttrEvent
    }
}

function Show-Whalecome ($additionalInfo = $false) {
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
    if ($additionalInfo) {
        if ($columns -gt 3) {
            Write-Weather
        }
        Write-Updates $columns $warningsData.Length
    }
}

Export-ModuleMember -Function Show-Whalecome
Export-ModuleMember -Function Show-Whale