function Get-NextcloudFolders() {
    $folders = [System.Collections.ArrayList]::new()
    Get-Content "$env:APPDATA\Nextcloud\nextcloud.cfg" | foreach-object -process {
        if ($_ -Match "localPath") {
            $keyValuePair = [regex]::split($_, '=')
            Write-Host $keyValuePair[1]
            $folders.Add([string]$keyValuePair[1])
        }
    }
    return $folders
}

function Get-NextcloudConfig() {
    $folders = Get-NextcloudFolders
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

Export-ModuleMember -Function ConvertToPdf
Export-ModuleMember -Function ConvertNextcloudDocumentsToPdf
Export-ModuleMember -Function Get-NextcloudConfig
Export-ModuleMember -Function Get-Scan