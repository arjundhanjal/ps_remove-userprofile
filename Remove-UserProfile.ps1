<#
  Remove-UserProfile.ps1 (v2)
  Copyright (C) 2015  Arjun Dhanjal

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  Contact information available at ArjunDhanjal.com

  Up and coming: network support.
#>

PARAM(
  [Parameter(Mandatory=$true)]
    [string]$SamAccountName,
  [switch]$ForceDelete
)

# Setting up some misc. variables...
$Domain = [Environment]::UserDomainName
$CurrentUser = [Environment]::UserName

# Importing the Active Directory PS module
Import-Module ActiveDirectory

If ($SamAccountName -eq $CurrentUser) {
  Write-Host -NoNewLine "ERROR: Sorry, this script cannot be used to delete your own user profile information." -ForegroundColor Red -BackgroundColor Black
  Write-Host "Script exiting... " -ForegroundColor Red -BackgroundColor Black
  Write-Host -NoNewLine "Press any key to continue..." -ForegroundColor Red -BackgroundColor Black
  Write-Host "" -ForegroundColor Red -BackgroundColor Black
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
  exit
}

Try { # Checking to see whether $SamAccountName actually exists in Active Directory...
  # Getting the user's SID which we need to delete/move the registry key associated with the user's profile
  $SID = (Get-ADUser $SamAccountName).SID.Value
}

    Catch { # If no user exists, script exits.
      Write-Host -NoNewLine "ERROR: Sorry, cannot find user " -ForegroundColor Red -BackgroundColor Black
      Write-Host -NoNewLine $Domain"\"$SamAccountName -ForegroundColor Cyan -BackgroundColor Black
      Write-Host "... " -ForegroundColor Red -BackgroundColor Black
      Write-Host -NoNewLine "Press any key to continue..." -ForegroundColor Red -BackgroundColor Black
      Write-Host "" -ForegroundColor Red -BackgroundColor Black
      $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
      exit }

Write-Host -NoNewLine "SID for user "
Write-Host -NoNewLine $SamAccountName -ForegroundColor Magenta
Write-Host -NoNewLine " is "
Write-Host -NoNewLine $SID -ForegroundColor Magenta
Write-Host "..."

# Renaming the user's profile folder

Try { Rename-Item C:\Users\$SamAccountName C:\Users\${SamAccountName}.old }

    Catch { # If no user folder exists, script exits.
      Write-Host -NoNewLine "ERROR: Sorry, cannot find folder " -ForegroundColor Red -BackgroundColor Black
      Write-Host -NoNewLine "C:\Users\$SamAccountName" -ForegroundColor Green -BackgroundColor Black
      Write-Host "... " -ForegroundColor Red -BackgroundColor Black
      Write-Host -NoNewLine "Press any key to continue..." -ForegroundColor Red -BackgroundColor Black
      Write-Host "" -ForegroundColor Red -BackgroundColor Black
      $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
      exit }

Write-Host -NoNewLine "Moved "
Write-Host -NoNewLine "C:\Users\$SamAccountName" -ForegroundColor Green
Write-Host -NoNewLine " to "
Write-Host -NoNewLine "C:\Users\$SamAccountName.old" -ForegroundColor Green
Write-Host "... "

# Renaming the registry key associated with the user's profile

Set-Location "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

Try { Rename-Item "$SID" "OLD-$SID" }

    Catch { # If no registry key exists, script exits.
      Write-Host -NoNewLine "ERROR: Sorry, cannot find registry key for SID " -ForegroundColor Red -BackgroundColor Black
      Write-Host -NoNewLine $SID -ForegroundColor Cyan -BackgroundColor Black
      Write-Host "... " -ForegroundColor Red -BackgroundColor Black
      Write-Host -NoNewLine "Press any key to continue..." -ForegroundColor Red -BackgroundColor Black
      Write-Host "" -ForegroundColor Red -BackgroundColor Black
      $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
      exit }

Write-Host -NoNewLine "Moved "
Write-Host -NoNewLine "HKLM:\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\ProfileList\$SID" -ForegroundColor Cyan
Write-Host -NoNewLine " to "
Write-Host -NoNewLine "...\OLD-$SID" -ForegroundColor Cyan
Write-Host "... "

# Setting the actions for the -ForceDelete switch. Deleting old user folders.

If($ForceDelete){
  Remove-Item "OLD-$SID"
  Set-Location "C:\Users"
  Remove-Item "$SamAccountName.old"
  }

# Set-Location out of registry and into user's home folder
Set-Location "C:\Users\$CurrentUser"
