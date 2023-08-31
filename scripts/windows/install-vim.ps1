#Requires -RunAsAdministrator

$NVimConfigDir = (Join-Path $Env:LocalAppData nvim)
$NvimDotfilesDir = (Join-Path (Split-Path $PSScriptRoot) vim)

If (Test-Path $NVimConfigDir) {
    Write-Warning "Neovim config directory already exists:"
    Get-Item -LiteralPath $NVimConfigDir
} Else {
    New-Item -ItemType SymbolicLink -Path $NVimConfigDir -Target $NvimDotfilesDir
}
