$Path = "$env:USERPROFILE\Memos.csv"

function Initialize-Memo([string]$text) {
    $Time = (Get-Date).ToString((Get-Culture).DateTimeFormat.ShortDatePattern)
    $Memo = New-Object -TypeName PSObject -Property @{
        Time = "$Time"
        Text = "$text"
    }
    return $Memo
}

function Get-MemoData {
    if (Test-Path $Path -pathType leaf) {
        $Memos = Import-Csv -Path $Path | Select-Object Time, Text
    }
    return $Memos
}
function Add-Memo([string]$text = "") {
    if ($text -eq "" ) { $text = Read-Host "Enter the text to memorize" }

    $Path = "~/Memos.csv"

    Initialize-Memo $text | Export-Csv -Path $Path -Append -Force

    Write-Output "$(Get-Emoji "Checkmark") saved to $Path"
    return
}

function Show-Memos {
    $Memos = Get-MemoData
    if (-not($Memos)) {
        Write-Host "no Memos saved yet"
        Write-Host "use [Add-Memo] to record a Memo"
    }
    $i = 0
    foreach ($Row in $Memos) {
        $Time = $Row.Time
        $Text = $Row.Text
        Write-Host "$($i.ToString().PadRight(3," ")) $Time  $Text"
        $i++
    }
    return
}
function Remove-Memo([int]$id) {
    $Memos = Get-MemoData
    $i = 0;
    $newMemos = @()
    foreach ($Memo in $Memos) {
        if (-not($i -eq $id)) {
            $newMemos += $Memo
        }
        $i++
    }
    if ($newMemos.Length -gt 0) {
        $newMemos | Select-Object Time, Text | Export-Csv -Path $Path
    }
    else {
        Remove-Item -Path $Path
    }
    return
}

Export-ModuleMember -Function Remove-Memo
Export-ModuleMember -Function Show-Memos
Export-ModuleMember -Function Add-Memo
Export-ModuleMember -Function Get-MemoData