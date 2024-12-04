# Set a permanent Environment variable, and reload it into $env
function Set-Environment([String] $variable, [String] $value) {
    Set-ItemProperty "HKCU:\Environment" $variable $value
    # Manually setting Registry entry. SetEnvironmentVariable is too slow because of blocking HWND_BROADCAST
    #[System.Environment]::SetEnvironmentVariable("$variable", "$value","User")
    Invoke-Expression "`$env:${variable} = `"$value`""
}

# Make code the default editor
Set-Environment "EDITOR" "code-insiders"
Set-Environment "GIT_EDITOR" $Env:EDITOR
# fix minGit for old wingetr
$minGitPath = Get-ChildItem -Path "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\" -Filter Git.MinGit* -ErrorAction SilentlyContinue -Force | ForEach-Object {$_.FullName}
if($minGitPath){
    Set-Environment "PATH" "$Env:PATH;$minGitPath\cmd"
}
