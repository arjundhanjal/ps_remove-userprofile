# Remove-UserProfile.ps1

This script is designed to aid in the rebuilding of corrupt or otherwise broken Windows user profiles.

This script is written to integrate with Active Directory, and thus will only work on domain networks. For this script to work properly, the user executing it must a) have access to read and query Active Directory, and b) be logged-on as a user **_other than_** the user whose profile needs to be rebuilt.

## The process

1. Importing the ActiveDirectory module

   First, the script imports PowerShell's **ActiveDirectory** module. For this to execute properly, the ActiveDirectory module must be [installed](https://technet.microsoft.com/en-us/magazine/gg413289.aspx) on the client computer.

2. Account validation and SID retrieval

   The script then takes the username specified in the `-SamAccountName` parameter and queries Active Directory to obtain the account's SID. The user's SID is needed when removing the registry keys associated with the user's profile. In effect, this also checks to see whether or not the user in question exists within Active Directory.

3. Moving files and folders

   The script then renames the user's profile folder (located in `C:\Users`), and finally, the  renames the registry keys associated with the user's profile, located at `HKLM:\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\ProfileList`.

## Other notes

At this time, the script does not support deleting user profiles over the network. I plan on adding this functionality at some point, but for now, I recommend executing this by first using `Enter-PSSession` to remote into the target computer.

By default, the script will just **rename** the user's profile folder and registry keys, and leave the administrator executing the script to delete the folders manually after they are done migrating data and other information. I have added a `-ForceDelete` switch that will force the **deletion** of these items should the administrator feel particularly confident in their abilities.
