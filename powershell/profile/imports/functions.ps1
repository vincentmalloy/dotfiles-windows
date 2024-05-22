# Basic commands
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }
function touch($file) { "" | Out-File $file -Encoding ASCII }

# Common Editing needs
function Edit-Hosts { Invoke-Expression "sudo $(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $env:windir\system32\drivers\etc\hosts" }
function Edit-Profile { Invoke-Expression "$(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $profile" }
function Edit-Dotfiles { Invoke-Expression "$(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $env:USERPROFILE\.dotfiles" }

# refresh path
function refreshPath() {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
# winget query if package is installed
function installed($id) {
    winget list --source winget -q $id | Out-Null
    if ($?) { return $true } else { return $false }
}
# System Update - Update Windows and installed software
function Update-System() {
    $isAdmin = $false
    $myIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal = new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    if ($myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $isAdmin = $true
    }
    Write-Host "checking for windows updates..."
    if ($isAdmin) {
        Install-WindowsUpdate -IgnoreUserInput -IgnoreReboot -AcceptAll
    }
    else {
        sudo Install-WindowsUpdate -IgnoreUserInput -IgnoreReboot -AcceptAll
    }
    Write-Host "done" -ForegroundColor Green
    Write-Host "checking for software updates..."
    winget update --all -s winget
    Write-Host "done" -ForegroundColor Green
    Write-Host "updating ubuntu packages..."
    ubuntu run "sudo apt update && sudo apt upgrade -y"
    # choco upgrade all
    Write-Host "all done!" -ForegroundColor Green
    if (Test-PendingReboot -SkipConfigurationManagerClientCheck | Select-Object -ExpandProperty IsRebootPending) {
        Write-Host "There is a reboot pending, reboot as soon as possible!" -ForegroundColor Red
    }
}
function Is-NetworkAvailable() {
    $networkavailable = $false;
    foreach ($adapter in Get-NetAdapter) {
        if ($adapter.status -eq "Up") { $networkavailable = $true; break; }
    }
    return $networkavailable
}
#set values in a json file
function Set-JsonData {
    param (
        $path,
        $setting,
        $value
    )
    
    $data = Get-Content -Raw -Path $path -ErrorAction silentlycontinue | ConvertFrom-Json
    if ($data) {
        if ($data.$setting) {
            $data.PSObject.Properties.Remove($setting)
        }
        $data | Add-Member -Name $setting -Value "$value" -MemberType NoteProperty
    }
    $data | ConvertTo-Json | Out-File $path -Encoding utf8
}

#convert files to pdf
function ConvertToPdf($files, $outFile) {
    Add-Type -AssemblyName System.Drawing
    $files = @($files)
    if (!$outFile) {
        $firstFile = $files[0] 
        if ($firstFile.FullName) { $firstFile = $firstFile.FullName }
        $outFile = $firstFile.Substring(0, $firstFile.LastIndexOf(".")) + ".pdf"
    }
    else {
        if (![System.IO.Path]::IsPathRooted($outFile)) {
            $outFile = [System.IO.Path]::Combine((Get-Location).Path, $outFile)
        }
    }

    try {
        $doc = [System.Drawing.Printing.PrintDocument]::new()
        $opt = $doc.PrinterSettings = [System.Drawing.Printing.PrinterSettings]::new()
        $opt.PrinterName = "Microsoft Print to PDF"
        $opt.PrintToFile = $true
        $opt.PrintFileName = $outFile

        $script:_pageIndex = 0
        $doc.add_PrintPage({
                param($sender, [System.Drawing.Printing.PrintPageEventArgs] $a)
                $file = $files[$script:_pageIndex]
                if ($file.FullName) {
                    $file = $file.FullName
                }
                $script:_pageIndex = $script:_pageIndex + 1

                try {
                    $image = [System.Drawing.Image]::FromFile($file)
                    $a.Graphics.DrawImage($image, $a.PageBounds)
                    $a.HasMorePages = $script:_pageIndex -lt $files.Count
                }
                finally {
                    $image.Dispose()
                }
            })

        $doc.PrintController = [System.Drawing.Printing.StandardPrintController]::new()

        $doc.Print()
        return $outFile
    }
    finally {
        if ($doc) { $doc.Dispose() }
    }
}

function ConvertNextcloudDocumentsToPdf() {
    $files = Get-ChildItem -Path $env:USERPROFILE\Nextcloud\Documents -Recurse -Include *.docx, *.doc, *.odt, *.jpeg, *.jpg, *.png, *.bmp, *.tiff, *.tif
    $files | ForEach-Object {
        # get the file dorectory path
        $dir = $_.DirectoryName
        Push-Location $dir
        # get the file name without extension
        $name = $_.Name.Substring(0, $_.Name.LastIndexOf("."))
        # check if filename ends in page number
        if ($name -match " p\d+$") {
            $name = $name.Substring(0, $name.LastIndexOf(" p"))
            #collect all pages
            $pages = $files | Where-Object { $_.Name -match "^$name p\d+\." }
            if (Test-Path "$name.pdf") {
                Write-Output "$name.pdf already exists"
                # remove the original file
                Remove-Item $_
                Pop-Location
                return
            }
            ConvertToPdf $pages "$name.pdf"
            # remove the original file
            Remove-Item $_
            Pop-Location
            return
        }
        # check if pdf file already exists
        if (Test-Path "$name.pdf") {
            Write-Output "$name.pdf already exists"
            # remove the original file
            Remove-Item $_
            Pop-Location
            return
        }
        # convert to pdf
        ConvertToPdf $_ "$name.pdf"
        # remove the original file
        Remove-Item $_
        Pop-Location
    }
}

function Get-Emoji($hex) {
    $EmojiIcon = [System.Convert]::toInt32($hex, 16)
    return [System.Char]::ConvertFromUtf32($EmojiIcon)
}

function caffeine() {
    Write-Host  "$(Get-Emoji 2615) staying awake... ([ctrl] + [c] to stop)`n"
    $wsh = New-Object -ComObject WScript.Shell
    $StartDate = Get-Date
    while (1) {
        $Duration = New-TimeSpan -Start $StartDate -End $(Get-Date)
        $span = Format-TimeSpan $Duration "m"
        # Send Shift+F15 - this is the least intrusive key combination I can think of and is also used as default by:
        # http://www.zhornsoftware.co.uk/caffeine/
        $wsh.SendKeys('+{F15}')
        if ($span) {
            Write-Host "`r$(Get-Emoji 0001F971) I have been awake for $span".PadRight($Host.UI.RawUI.WindowSize.Width, " ") -NoNewline
        }
        Start-Sleep -seconds 59
    }
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

function Get-Uptime {
    Get-WmiObject win32_operatingsystem | Select-Object @{LABEL = 'LastBootUpTime';
        EXPRESSION                                              = { $_.ConverttoDateTime($_.lastbootuptime) }
    }
}

function uptime {
    $uptime = New-TimeSpan -Start $(Get-Uptime | Select-Object -ExpandProperty LastBootUpTime) -End $(Get-Date)
    return "last Boot-up was $(Format-TimeSpan $uptime "s" $true) ago"
}

Function Get-PublicIP {
 (Invoke-WebRequest http://ifconfig.me/ip ).Content
}