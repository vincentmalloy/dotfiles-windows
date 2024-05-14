# dotfiles-windows

## bootstrapping

```powershell
Start-Process -FilePath powershell -ArgumentList "-Command $(Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/vincentmalloy/dotfiles-windows/main/bootstrap.ps1).Content" -Wait
```
