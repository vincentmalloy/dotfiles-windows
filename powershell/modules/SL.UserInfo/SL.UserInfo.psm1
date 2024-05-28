$infoSchema = @{
    Name = "Enter your Full Name";
    Email = "Enter your Email Adress";
    Location = "Enter your Location"
}

$infoPath = "$env:USERPROFILE\.dotfiles\user_info.json"

function Get-UserInfo() {
    Set-UserInfo
    if(Test-Path $infoPath){
        $userInfo = Get-Content -Path $infoPath | ConvertFrom-Json
    }
    return $userInfo
}

function Set-UserInfo($force=$false) {
    $userInfo = @{}
    if(Test-Path $infoPath){
        $userInfo = Get-Content -Path $infoPath | ConvertFrom-Json -AsHashtable
    }
    if($force -or !($userInfo)){
        $keysToUpdate = @($infoSchema.Keys)
    }else{
        $keysToUpdate = Compare-Object @($userInfo.Keys) @($infoSchema.Keys) -Passthru
    }
    $keysToUpdate | ForEach-Object{
        $userInfo.$_ = Read-Host $infoSchema.$_
    }
    ConvertTo-Json -InputObject $userInfo | Out-File -FilePath $infoPath -Force
    return
}
function New-CustomModule($Name = "", $Manifest = $false) {
    # kickstart a new module with or without a manifest
    if($Name -eq ""){
        $Name = Read-Host "Enter module name"
    }
    $userInfo = Get-UserInfo
    $modulePath = ($env:PSModulePath -split ';' | Select-Object -First 1)
    $moduleName = "$((($userInfo.Name -split ' ') | ForEach-Object -process { $_.SubString(0,1).ToUpper() }) | Join-String -Separator '').$Name"
    if(Test-Path "$modulePath\$moduleName"){
        Write-Host "Module $moduleName already exists"
    }else{
        sudo New-Item -ItemType Directory -Path "$env:USERPROFILE\.dotfiles\powershell\modules\$moduleName"
        sudo New-Item -ItemType File -Path "$env:USERPROFILE\.dotfiles\powershell\modules\$moduleName\$moduleName.psm1"
        sudo New-Item -Path "$modulePath\$moduleName" -ItemType SymbolicLink -Value "$env:USERPROFILE\.dotfiles\powershell\modules\$moduleName" -Force | Out-Null
    }
    if($Manifest){
        New-ModuleManifest -Path "$env:USERPROFILE\.dotfiles\powershell\modules\$moduleName\$moduleName.psd1" -ModuleVersion "0.1" -Author $userInfo.Name
        Import-Module $moduleName
    }
}

Export-ModuleMember -Function New-CustomModule
Export-ModuleMember -Function Get-UserInfo
Export-ModuleMember -Function Set-UserInfo