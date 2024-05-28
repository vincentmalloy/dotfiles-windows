function Test-PendingReboot{
    return Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
}

function Get-LastBootupTime {
    Get-CimInstance -ClassName win32_operatingsystem | Select-Object -Property lastbootuptime
}

function Get-Uptime {
    $uptime = New-TimeSpan -Start $(Get-LastBootupTime | Select-Object -ExpandProperty LastBootUpTime) -End $(Get-Date)
    return $uptime
}

function Format-TimeSpan($Duration, $unit = "s", $short = $false ) {
    $span = ""
    $Day = switch ($Duration.Days) {
        0 { $null; break }
        1 { "{0} Day" -f $Duration.Days; break }
        Default { "{0} Days" -f $Duration.Days }
    }
    if (($short -and $Day)) {
        return $Day
    }
    $span += "$Day"
    if ($unit -eq "d") {
        return $span
    }
    $Hour = switch ($Duration.Hours) {
        0 { $null; break }
        1 { "{0} Hour" -f $Duration.Hours; break }
        Default { "{0} Hours" -f $Duration.Hours }
    }
    if ($short -and $Hour) {
        return $Hour
    }
    if ($span -and $Hour) {
        $span += ", "
    }
    $span += "$Hour"
    if ($unit -eq "h") {
        return $span
    }
    $Minute = switch ($Duration.Minutes) {
        0 { $null; break }
        1 { "{0} Minute" -f $Duration.Minutes; break }
        Default { "{0} Minutes" -f $Duration.Minutes }
    }
    if ($short -and $Minute) {
        return $Minute
    }
    if ($span -and $Minute) {
        $span += ", "
    }
    $span += "$Minute"
    if ($unit -eq "m") {
        return $span
    }
    $Second = switch ($Duration.Seconds) {
        # 0 { $null; break }
        1 { "{0} Second" -f $Duration.Seconds; break }
        Default { "{0} Seconds" -f $Duration.Seconds }
    }
    if ($short -and $Second) {
        return $Second
    }
    if ($span -and $Second) {
        $span += " and "
    }
    $span += "$Second"
    return $span
}

Export-ModuleMember -Function Test-PendingReboot
Export-ModuleMember -Function Get-Uptime
Export-ModuleMember -Function Format-TimeSpan