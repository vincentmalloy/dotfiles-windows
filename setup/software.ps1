
$softwarePackageIds = @(
    'Git.MinGit',
    'KeePassXCTeam.KeePassXC',
    'Microsoft.VisualStudioCode.Insiders',
    'Nextcloud.NextcloudDesktop',
    'JanDeDobbeleer.OhMyPosh',
    '7zip.7zip',
    'Mozilla.Firefox',
    'Mozilla.Thunderbird',
    'Helix.Helix',
    'Microsoft.WindowsTerminal.Preview',
    'gerardog.gsudo',
    'Microsoft.OpenSSH.Beta',
    'Microsoft.Sysinternals.PsTools',
    'Valve.Steam'
)
$highest=0
$softwarePackageIds | ForEach-Object {
    if($_.Length -gt $highest){
        $highest = $_.Length
    }
}
# remove microsoft store form winget sources
winget source remove msstore | Out-Null
$softwarePackageIds | ForEach-Object {$i=1} {
    Write-Host -NoNewLine $("`rChecking   (" + (('{0:d4}' -f $i) + " of " + ('{0:d4}' -f $softwarePackageIds.Length)) + ") $_" + (" " * ($highest - $_.Length)))
    $isInstalled = (winget list --source winget --id $_)
    if(!($isInstalled.Length -gt 4)){
        Write-Host -NoNewLine $("`r" + "Installing (" + (('{0:d4}' -f $i) + " of " + ('{0:d4}' -f $softwarePackageIds.Length)) + (&{if($i -eq $softwarePackageIds.Length) {"`n"}}) + ") $_" + (" " * ($highest - $_.Length)))
        winget install --source winget --id $_ --silent --accept-package-agreements | Out-Null
    }
    $i++
}
