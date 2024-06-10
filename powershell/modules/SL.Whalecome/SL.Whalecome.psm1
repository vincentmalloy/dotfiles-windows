Import-Module SL.TerminalOutput
Import-Module SL.Memos
Import-Module SL.UsefulFunctions

$maxHeight = 25
$columnMinWidth = 40
$columns = [System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columnMinWidth)
$columnWidth = [System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columns)

class UiTable {
    [int] $entries
    [int] $x
    [int] $y
    [int] $width
    [ordered] $strings = @{}
    
    UiTable() { $this.Init() }
    UiTable($x, $y, $width) {
        $this.Init()
        $this.x = $x
        $this.y = $y
        $this.width = $width
    }
    [void] Init() {
        $this.entries = 25
        for ($i = 0; $i -lt $this.entries; $i++) {
            $this.strings.Add([string]$i, " ")
        }
        $this.x = 0
        $this.y = 0
        $this.width = 40
    }

    [void] Update([int]$key, [string]$string) {
        $string = $(if ($string.length -ge $this.width) { $string.substring(0, $this.width) } else { $string.PadRight($this.width, " ") })
        $this.strings.[string]$key = $string
    }
    [void] Update([int]$key, [string]$string, [bool]$reDraw) {
        $string = $(if ($string.length -ge $this.width) { $string.substring(0, $this.width) } else { $string.PadRight($this.width, " ") })
        $this.strings.[string]$key = $string
        if ($reDraw) {
            $offset = 0
            $this.strings.values | ForEach-Object {
                Write-ToPosition -text "$($_.PadRight($this.width, " "))" -left $this.x -top ($this.y + $offset)
                $offset++
            }
        }
    }
    [void] Update([int]$start, [string[]]$stringArray) {
        for ($i = 0; $i -lt $stringArray.Length; $i++) {
            if (($i + $start) -lt $this.entries) {
                $string = $(if ($stringArray[$i].length -ge $this.width) { $stringArray[$i].substring(0, $this.width) } else { $stringArray[$i].PadRight($this.width, " ") })
                $this.strings.[string]$($i + $start) = $string
            }
        }
    }
    [void] Update([int]$start, [string[]]$stringArray, [bool]$reDraw) {
        for ($i = 0; $i -lt $stringArray.Length; $i++) {
            if (($i + $start) -lt $this.entries) {
                $string = $(if ($stringArray[$i].length -ge $this.width) { $stringArray[$i].substring(0, $this.width) } else { $stringArray[$i].PadRight($this.width, " ") })
                $this.strings.[string]$($i + $start) = $string
            }
        }
        if ($reDraw) {
            $offset = 0
            $this.strings.values | ForEach-Object {
                Write-ToPosition -text "$($_.PadRight($this.width, " "))" -left $this.x -top ($this.y + $offset)
                $offset++
            }
        }
    }
    
    [array] getStringArray() {
        $array = @()
        $this.strings.values | ForEach-Object -Process {
            $array += "$([string]$_)"
        }
        return $array
    }

    [void] getScriptData($name, $scriptBlock, $key, $argumentList) {
        New-Variable -Name "$name.var.object" -Scope Global -Option AllScope -Value $this
        New-Variable -Name "$name.var.key" -Scope Global -Option AllScope -Value $key
        # New-Variable -Name "$name.var.maxWidth" -Scope Global -Option AllScope -Value $dimensions.MaxWidth
        New-Variable -Name "$name.var.job" -Value (Start-Job -Name "$name.job" -ScriptBlock $scriptBlock -ArgumentList $argumentList)
        $null = Register-ObjectEvent -InputObject (Get-Variable -Name "$name.var.job" -ValueOnly) -EventName StateChanged -MessageData (Get-Variable -Name "$name.var.job" -ValueOnly).Id -SourceIdentifier "$name.job.monitor" -Action ({
                $name = $event.sender.Name -split "\." | Select-Object -First 1
                $result = Receive-Job $event.sender.Id
                $text = $result.text
                if ($result.hex) {
                    $text = "$(ConvertFrom-Utf16Hex $result.hex) $text"
                }
                $(Get-Variable -Name "$name.var.object" -ValueOnly).Update($(Get-Variable -Name "$name.var.key" -ValueOnly), $text, $true)
                Get-Job -Name "$name.job*" | Stop-Job
                Get-Job -Name "$name.job*" | Remove-Job
                Unregister-Event $event
                Remove-Event $event
                Remove-Variable -Scope Global -Name "$name.var.*"
            })
    }
}

function Get-Art {
    $data = Get-Content "$PSScriptRoot\ascii-art.txt"
    return [string[]]@($data)
}

function Get-Memos {
    $data = New-Object System.Collections.Generic.List[System.Object]
    $data.Add("$(Get-Emoji "Page") Memos:")
    $data.Add("$($PSStyle.Foreground.BrightBlack)$($PSStyle.Dim)use $($PSStyle.Italic)[Add-Memo]$($PSStyle.Reset)$($PSStyle.Foreground.BrightBlack)$($PSStyle.Dim) to record a Memo$($PSStyle.Reset)")
    $data.Add(" ")
    # $data = @(
    #     "$(Get-Emoji "Page") Memos:"
    #     ""
    # )
    $Memos = Get-MemoData
    if ($Memos) {
        $Memos | ForEach-Object -process {
            $data.Add("$($_.Time)  $($_.Text)")
        }
    }
    else {
        $data.Add("use [Add-Memo] to record a Memo")
    }
    
    return $data.ToArray()
}

# function Color-String($color, $string) {
#     return "$("$([char]0x1b)[$($color)m")$string$("$([char]0x1b)[0m")"
# }

# function Get-Messages {
#     $data = @(
#         "$(Get-Emoji "WavingHand") Hello $Env:UserName!"
#         ""
#         "Today is $((Get-Date).ToString((Get-Culture).DateTimeFormat.LongDatePattern))"
#         ""
#         "$(uptime)"
#         ""
#     )
#     $data += "Free Disk Space:"
#     $data += ""
#     (Get-CimInstance -Class Win32_LogicalDisk | Select-Object -Property DeviceID, VolumeName, @{Label = 'FreeSpace (Gb)'; expression = { ($_.FreeSpace / 1GB).ToString('F2') } }, @{Label = 'Total (Gb)'; expression = { ($_.Size / 1GB).ToString('F2') } }, @{label = 'FreePercent'; expression = { [Math]::Round(($_.freespace / $_.size) * 100, 2) } }) | ForEach-Object -process {
#         $data += "$($_.VolumeName.PadRight(8," ")) ($($_.DeviceID)) $($_."FreeSpace (Gb)".PadLeft(8," ")) GB ($($_.FreePercent)%)"    
#     }
#     return $data
# }


# function Get-Software {
#     $data = @(
#         "$(Get-Emoji "Floppy")  Software:"
#         ""
#     )
#     if (Test-PendingReboot) {
#         $data += "$updateWarnChar System Reboot Pending"
#     }
#     $psDrive = Get-PSDrive "C"
#     $spaceTotal = $psDrive.Used + $psDrive.Free
#     $percentageUsed = [math]::Round(($psDrive.Used / $spaceTotal) * 100)
#     if ($percentageUsed -gt 85) {
#         $data += "$updateWarnChar System Drive C: is almost Full! ($percentageUsed % - $([System.Math]::Floor($psDrive.Used/1GB)) of $([System.Math]::Floor($spaceTotal/1GB)) GB)"
#     }

#     return $data
# }

function Show-Whale {
    $columns = [System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columnMinWidth)
    $columnWidth = [System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columns)
    $whale = Get-Art
    $whale += ""
    Clear-Host
    Show-Data $whale ($columnWidth * ($columns - 1)) 1
}

function Get-WeatherJob([string]$location = "idar-oberstein") {
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
        # $lines = $result -split [System.Environment]::NewLine
        $lines = $result.Split(
            @("`r`n", "`r", "`n"), 
            [StringSplitOptions]::None)
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

function Build-SoftwareColumn($left, $top, $width) {
    $softwareColumn = [UiTable]::new($left, $top, $width)
    $softwareColumn.Update(0, "$(Get-Emoji "Floppy") Software")
    $softwareColumn.Update(1, "$($PSStyle.Foreground.BrightBlack)$($PSStyle.Dim)to update run $($PSStyle.Italic)Update-System$($PSStyle.Reset)")
    $softwareColumn.Update(3, "checking for software updates...")
    $softwareScriptBlock = {
        $result = New-Object PSObject -Property @{
            text = ""
            hex  = ""
        }
        $softwareUpgrades = winget upgrade | Select-Object -Last 1
        if (-not($softwareUpgrades.subString(0, 2) -eq "No")) {
            $result.text = "$($PSStyle.Foreground.Yellow)winget: $softwareUpgrades$($PSStyle.Reset)"
            $result.hex = "2757"
        }
        else {
            $result.text = "winget: no upgrades to install."
            $result.hex = "2705"
        }
        return $result
    }
    $softwareColumn.getScriptData("winget", $softwareScriptBlock, 3, "")
    $softwareColumn.Update(4, "checking for windows updates...", $true)


    $softwareScriptBlock2 = {
        $result = New-Object PSObject -Property @{
            text = ""
            hex  = ""
        }
        if (sudo Get-WindowsUpdate -NotCategory "Drivers") {
            $result.text = "$($PSStyle.Foreground.Yellow)Windows: updates available.$($PSStyle.Reset)"
            $result.hex = "2757"
        }
        else {
            $result.text = "Windows: no updates to install."
            $result.hex = "2705"
        }
        return $result
    }
    $softwareColumn.getScriptData("windowsUpdate", $softwareScriptBlock2, 4, "")
    $softwareColumn.Update(5, "checking for chocolatey updates...", $true)

    $softwareScriptBlock3 = {
        $result = New-Object PSObject -Property @{
            text = ""
            hex  = ""
        }
        choco outdated | out-null
        if($LASTEXITCODE -eq 2){
            $result.text = "$($PSStyle.Foreground.Yellow)Chocolatey: upgrades available.$($PSStyle.Reset)"
            $result.hex = "2757"
        }elseif($LASTEXITCODE -eq 0){
            $result.text = "Chocolatey: no upgrades to install."
            $result.hex = "2705"
        }else{
            $result.text = "$($PSStyle.Foreground.Red)Chocolatey: an error has occured.$($PSStyle.Reset)"
            $result.hex = "26A0"
        }
        return $result
    }
    $softwareColumn.getScriptData("Chocolatey", $softwareScriptBlock3, 5, "")
}

function Build-WhaleColumn($left, $top, $width) {
    $whaleColumn = [UiTable]::new($left, $top, $width)
    $whale = Get-Art
    $whaleColumn.Update(0, [string[]]@($whale), $true)
}

function Build-MemosColumn($left, $top, $width) {
    $memosColumn = [UiTable]::new($left, $top, $width)
    $memos = Get-Memos
    $memosColumn.Update(0, [string[]]$memos, $true)
}

function Build-InfoColumn($left, $top, $width) {
    $infoColumn = [UiTable]::new($left, $top, $width)
    $infos = @(
        "$(Get-Emoji "WavingHand") Hello $Env:UserName!"
        ""
        ""
        "Today is $((Get-Date).ToString((Get-Culture).DateTimeFormat.LongDatePattern))"
        ""
        "Time since last Reboot:"
        "$(Format-TimeSpan $(Get-Uptime))"
    )
    $infoColumn.Update(10, "checking weather...")
    $infoColumn.Update(0, [string[]]$infos, $true)
    $location = (Get-UserInfo) | Select-Object -ExpandProperty Location
    $argumentList = "$location"
    $scriptBlock = {
        param($location)
        $result = New-Object PSObject -Property @{
            text = ""
            hex  = ""
        }
        $result.text = invoke-RestMethod "https://wttr.in/$($location)?format=`"%l:+%c+%t+%m\n`""
        return $result
    }
    $infoColumn.getScriptData("wttr", $scriptBlock, 10, $argumentList)
}
function Show-Whalecome {
    Clear-Host
    for ($i = 0; $i -lt 25; $i++) {
        Write-Host ""
    }
    $columns = [System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columnMinWidth)
    if ($columns -gt 4) {
        $columns = 4
    }
    $columnWidth = ([System.Math]::Floor($Host.UI.RawUI.WindowSize.Width / $columns))
    if ($columns) {
        Build-InfoColumn 0 1 ($columnWidth - 1)
    }
    if ($columns -gt 1) {
        Build-MemosColumn $columnWidth 1 ($columnWidth - 1)
    }
    if ($columns -gt 2) {    
        Build-SoftwareColumn ($columnWidth * 2) 1 ($columnWidth - 1)
    }
    if ($columns -gt 3) {    
        Build-WhaleColumn ($columnWidth * 3) 1 ($columnWidth - 1)
    }
}
Export-ModuleMember -Function Show-Whale
Export-ModuleMember -Function Show-Whalecome