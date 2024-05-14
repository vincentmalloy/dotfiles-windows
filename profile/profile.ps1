Push-Location ("$(Split-Path $profile.currentUserAllHosts)\imports")
"exports","aliases","functions","components" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location