# dotfiles-windows

## bootstrapping

```powershell
Set-ExecutionPolicy ByPass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;Invoke-Expression ((New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/vincentmalloy/dotfiles-windows/main/bootstrap.ps1"))
```