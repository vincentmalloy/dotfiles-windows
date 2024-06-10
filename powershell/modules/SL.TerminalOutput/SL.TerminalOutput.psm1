$emojis = @{
    Floppy = "1F4BE";
    Exclamation = "2757";
    Checkmark = "2705";
    WavingHand = "1F44B";
    Coffee = "2615";
    Page = "1F4C3"
}

function ConvertFrom-Utf16Hex($hex){
    $char = [System.Convert]::toInt32($hex, 16)
    return [System.Char]::ConvertFromUtf32($char)
}

function Get-Emoji([string]$icon){
    if($emojis.$icon){
        return ConvertFrom-Utf16Hex $emojis.$icon
    }else{
        Write-Host "Possible Values:`n"
        $emojis.keys | ForEach-Object {
            Write-Host $_
        }
    }
}

function Write-ToPosition {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$text,
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "position")]
        [psobject]$position,
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName = "xy")]
        [int]$left,
        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = "xy")]
        [int]$top
    )
    switch ($PsCmdlet.ParameterSetName) {
        "xy" {
            $position = New-Object PSObject -Property @{
                Left = $left
                Top  = $top
            }
        }
    }
    $cursor = New-Object PSObject -Property @{
        Top  = [console]::CursorTop
        Left = [console]::CursorLeft
    }
    [console]::setcursorposition($position.Left, $position.Top)
    Write-Host "$text" -NoNewline
    [console]::setcursorposition($cursor.Left, $cursor.Top)
    return
}

function Get-AnsiColor($color, $string) {
    return "$("$([char]0x1b)[$($color)m")$string$("$([char]0x1b)[0m")"
}

Export-ModuleMember -Function Write-ToPosition
Export-ModuleMember -Function ConvertFrom-Utf16Hex
Export-ModuleMember -Function Get-Emoji
Export-ModuleMember -Function Get-AnsiColor