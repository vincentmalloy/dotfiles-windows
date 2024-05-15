# Basic commands
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }
function touch($file) { "" | Out-File $file -Encoding ASCII }

# Common Editing needs
function Edit-Hosts { Invoke-Expression "sudo $(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $env:windir\system32\drivers\etc\hosts" }
function Edit-Profile { Invoke-Expression "$(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $profile" }
function Edit-Dotfiles  { Invoke-Expression "$(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $env:USERPROFILE\.dotfiles" }

# refresh path
function refreshPath() {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
# winget query if package is installed
function installed($id) {
    winget list --source winget -q $id | Out-Null
    if ($?) {  return $true } else { return $false }
}
# System Update - Update Windows and installed software
function Update-System() {
    Write-Host "checking for windows updates..."
    sudo Install-WindowsUpdate -IgnoreUserInput -IgnoreReboot -AcceptAll
    Write-Host "done" -ForegroundColor Green
    Write-Host "checking for software updates..."
    sudo winget update --all -s winget
    Write-Host "done" -ForegroundColor Green
    Write-Host "updating ubuntu packages..."
    ubuntu run "sudo apt update && sudo apt upgrade -y"
    # choco upgrade all
    Write-Host "all done!" -ForegroundColor Green
}

#set values in a json file
function Set-JsonData{
    param (
        $path,
        $setting,
        $value
    )
    
    $data = Get-Content -Raw -Path $path -ErrorAction silentlycontinue | ConvertFrom-Json
    if($data){
        if($data.$setting) {
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
    } else {
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

function ConvertNextcloudDocumentsToPdf(){
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

