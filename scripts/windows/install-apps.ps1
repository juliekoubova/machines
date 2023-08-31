Function Install($Id) {
    Write-Host "Installing $Id..."
    & winget install `
        --id=$Id `
        --source=winget `
        --accept-source-agreements `
        --accept-package-agreements `
        --disable-interactivity
}

Install 7zip.7zip
Install AgileBits.1Password
Install AngusJohnson.ResourceHacker
Install CoreyButler.NVMforWindows
Install Debian.Debian
Install Docker.DockerDesktop
Install Elgato.ControlCenter
Install gerardog.gsudo
Install Git.Git
Install JesseDuffield.lazygit
Install LLVM.LLVM
Install Microsoft.DotNet.SDK.7
Install Microsoft.PowerShell
Install Microsoft.PowerToys
Install Microsoft.VisualStudioCode.Insiders
Install Microsoft.WindowsTerminal
Install Neovim.Neovim
Install Prusa3D.PrusaSlicer
Install QMK.QMKToolbox
Install Rustlang.Rust.MSVC
Install Starship.Starship
Install VideoLAN.VLC
Install WinDbgNext
Install icsharpcode.ILSpy

dotnet tool install -g dotnet-vs
