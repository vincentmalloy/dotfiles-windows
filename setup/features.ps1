# add media feature pack (video playback will not work in firefox otherwise)
if($(Get-WindowsCapability -online | Where-Object -Property name -like "Media.MediaFeaturePack*" | Select-Object -ExpandProperty "State") -ne "Installed"){
    Get-WindowsCapability -online | Where-Object -Property name -like "Media.MediaFeaturePack*" | Add-WindowsCapability -Online
}
# add dependencies
# if(!(Get-AppxPackage | Where-Object -Property name -like "Microsoft.VCLibs.14*")){
#     Add-AppxPackage .\setup\dependencies\Microsoft.VCLibs.x64.14.00.Desktop.appx
# }
# install wsl
if(!(wsl -l)){
    wsl --set-default-version 2
    wsl --install --no-distribution
    wsl --set-default-version 2
}
if(!(wsl -l | Where-Object {$_.Replace("`0","") -match '^NixOS'})){
    $repo = "nix-community/NixOS-WSL"
    $filename = "nixos-wsl.tar.gz"
    
    $download = "https://github.com/$repo/releases/latest/download/$filename"
    
    # Invoke-WebRequest $download -Out $filename

    wsl --import NixOS $env:USERPROFILE\NixOS\ $filename --version 2
    
    # Remove-Item $filename
    $hostname = "voyager2"
    $githubUser = "vincentmalloy"
    $flakeRepo = "nixos-config"
    # $flakeFolder = "/mnt/c/Users/${env:USERNAME}/nix-config"
    # $flake = "$flakeFolder#$hostname"
    $flake = "github:/$githubUser/$flakeRepo#$hostname"
    wsl -d NixOS sudo nixos-rebuild switch --flake $flake
    wsl -t NixOS
    # checkout flake and link it to /etc/nixos
    wsl -d NixOS sudo rm -rf /etc/nixos
    wsl -d NixOS git clone "https://github.com/$githubUser/$flakeRepo.git" ~/$flakeRepo
    wsl -d NixOS sudo ln -s ~/$flakeRepo /etc/nixos
    # wsl -d NixOS sudo ln -s $flakeFolder /etc/nixos
    wsl -d NixOS sudo nixos-rebuild switch
    wsl -t NixOS
    wsl -s NixOS
}
