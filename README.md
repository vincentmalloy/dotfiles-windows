# dotfiles-windows

## bootstrapping

```powershell
Start-Process -FilePath powershell -ArgumentList "-Command $(Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/vincentmalloy/dotfiles-windows/bootstrap.ps1).Content"
```