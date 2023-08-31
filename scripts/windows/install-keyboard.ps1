#Requires -RunAsAdministrator

Function Set-ScancodeMap {
  Param (
    [Parameter(Position = 0, Mandatory)]
    [AllowEmptyCollection()]
    [Hashtable]
    $Map
  )
  
  $MemoryStream = New-Object System.IO.MemoryStream
  $BinaryWriter = New-Object System.IO.BinaryWriter $MemoryStream
  
  # https://learn.microsoft.com/en-us/windows-hardware/drivers/hid/keyboard-and-mouse-class-drivers
  $BinaryWriter.Write([UInt32]0) # version
  $BinaryWriter.Write([UInt32]0) # flags
  $BinaryWriter.Write([UInt32]$Map.Count + 1) # +1 for terminator
  
  ForEach ($Entry In $Map.GetEnumerator()) {
    $BinaryWriter.Write([UInt16]$Entry.Value)
    $BinaryWriter.Write([UInt16]$Entry.Key)
  }
  
  $BinaryWriter.Write([UInt32]0) # terminator
  
  Set-ItemProperty `
    -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' `
    -Name        'Scancode Map' `
    -Value       $MemoryStream.ToArray() `
    -Type        Binary
}


# Apple Magic Keyboard: Fn keys work as Fn keys by default
$KeyMagic2 = 'HKLM:\SYSTEM\CurrentControlSet\Services\KeyMagic2'
If (Test-Path $KeyMagic2) {
  Set-ItemProperty -LiteralPath $KeyMagic2 -Name OSXFnBehavior -Value 0 -Type Binary
}

If (-Not (Get-PSDrive HKU -ea SilentlyContinue)) {
  $Null = New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
}

# NumLock ON by default
Set-ItemProperty -LiteralPath 'HKCU:\Control Panel\Keyboard' -Name InitialKeyboardIndicators -Value 2 -Type DWord
Set-ItemProperty -LiteralPath 'HKU:\.DEFAULT\Control Panel\Keyboard' -Name InitialKeyboardIndicators -Value 2 -Type DWord

[UInt16] $CapsLock = 0x3a
[UInt16] $LControl = 0x1d
Set-ScancodeMap @{ $CapsLock = $LControl }
