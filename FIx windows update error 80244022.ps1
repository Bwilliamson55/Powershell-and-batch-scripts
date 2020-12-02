### Rename software distribution backup folders
#
### This will check for the two software distrib folders, back them up via renaming them, then ask for a reboot.
### If the backup folders already exist, it will prompt for the go-ahead to replace them
#
### This process should fix a lot of windows update errors- especially when you check for updates, and the check fails with errors 80244022.
#
# update as of 2020- I don't remember what windows OS this was for, but I'm betting win7 maybe useful tidbits still in here.

#Check for PS ver 3+

Write-Host "Checking Powershell Version..." `r
if ($PSVersionTable.PSVersion.Major -lt "3") {
Write-Host "Powershell Version too low." -fore yellow
Write-Host `r "You're PS version is " $PSVersionTable.PSVersion
Write-Host `r "You must update to Windows Management Framework 5 for the best experience."
Read-Host "Press any Key to Exit"
Exit
}
Else
{
Write-Host "Powershell version " $PSVersionTable.PSVersion.Major " Is good."
} 

function RM-Ren-Fldr ($Folder, $NewName) {    
$title = "Remove Folder"
$message = "Do you want to Overwrite ${NewName}?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Removes the ${NewName} then replaces with a backup of ${Folder}"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Does Not Do anything and Quits."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 

switch ($result)
    {
        0 {"Renaming $Folder to $NewName"; try { rm $NewName -force; ren $Folder $NewName; } catch { "Sorry, this didn't work!"}}
        1 {"You selected No."; Read-Host "Press any Key to Exit"; Exit}
    }
}

function HAWLT ($service) {
$Serv = Get-service $service
Write-Host `r`n "Stopping " $serv.displayname " Service..."
stop-service $serv -force
While ($serv.status -ne "Stopped") {
Write-Host "Waiting for " $serv.displayname " Service to stop..."
Start-Sleep -s 2
}
}

function MAHCH ($service) {
$Serv = Get-service $service
Write-Host `r`n "Starting " $serv.displayname " Service..."
Start-service $serv
    While ($serv.status -ne "Running") {
        Write-Host "Waiting for " $serv.displayname " Service to Start..."
        Start-Sleep -s 2
    }
}

$SD = "$env:SystemRoot\SoftwareDistribution"
$CR = "$env:SystemRoot\system32\catroot2"

Write-Host "WARNING! This will rename your Software Distribution Folder ( $SD ), and Catroot2 folder ( $CR ) with a .bak extension!" -fore yellow
Read-Host `r "Press any Key to Continue"

HAWLT wuauserv
HAWLT cryptSvc
HAWLT bits
HAWLT msiserver


if (Test-Path -Path $SD) {
    write-Host "Found Software Distribution Folder."
    write-Host `r`n "Renaming Software Distribution folder from $SD to ${SD}.bak"
        try { 
            if (Test-Path -Path "${SD}.bak"){
                Write-Host "${SD}.bak exists"
                RM-Ren-Fldr $SD "${SD}.bak"
            } Else {
            Ren $SD "${SD}.bak" -force
            }
        }
        Catch {
            write-host "Sorry, that didn't work."
        }

} Else {
    Write-Host "$SD Not Found!! Exiting!"
    Read-Host "Press any Key to exit"
    Exit
}
if (Test-Path -Path $CR) {
    write-Host "Found Software Distribution Folder."
    write-Host `r`n "Renaming Software Distribution folder from $CR to ${CR}.bak"
        try { 
            if (Test-Path -Path "${CR}.bak"){
                Write-Host "${CR}.bak exists"
                RM-Ren-Fldr $CR "${CR}.bak"
            } Else {
            Ren $CR "${CR}.bak" -force
            }
        }
        Catch {
            write-host "Sorry, that didn't work."
        }

} Else {
    Write-Host "$CR Not Found!! Exiting!"
    Read-Host "Press any Key to exit"
    Exit
}

MAHCH wuauserv
MAHCH cryptSvc
MAHCH bits
MAHCH msiserver

Write-Host `r`n "You must Reboot Your PC for changes to take effect." -fore yellow
Read-Host `r`n "Press any Key to Exit" 