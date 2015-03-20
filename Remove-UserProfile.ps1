<#
  Remove-UserProfile.ps1
  Developed by Arjun Dhanjal
  v1, March 2015

  Up and coming: network support.
#>

PARAM(
  [Parameter(Mandatory=$true)]
    [string]$SamAccountName
)

# Setting up some misc. variables...
$Domain = [Environment]::UserDomainName
$CurrentUser = [Environment]::UserName

# Importing the Active Directory PS module
Import-Module ActiveDirectory

Try { # Checking to see whether AD user actually exists...
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

# Set-Location out of registry and into home folder
Set-Location "C:\Users\$CurrentUser"
