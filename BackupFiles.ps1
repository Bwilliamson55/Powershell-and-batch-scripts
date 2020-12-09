#
#Recursive Incremental Folder Backup
#Last updated 8/24/19 By Bwilliamson
#
#Using parameters, copy a folders newest content, retaining structure to a designated folder.
#Using xcopy we're only copying files that are newer than already copied files. 
#
#Example: PS:>.\FolderBackup.ps1 "C:\the\source\dir" "C:\the\destination"
#Will copy files touched since the last copy. (don't use \ on the end of the paths)
#

Param(
  [Parameter(Mandatory=$true, position=0)][string]$source,
  [Parameter(Mandatory=$true, position=1)][string]$destination
  #old version reminder
  #[Parameter(Mandatory=$true, position=2)][ValidateSet("lt", "gt")][string]$operator,
  #[Parameter(Mandatory=$true, position=3)][Int]$hours
)

function logwrite {
Add-Content -Path $logpath -Value $args
}

#Enable writing to log path?
$uselog = 1
$logpath = "C:\Users\USER\Desktop\BackupScript\log.txt"

$src = $source.toLower()
$dest = $destination.toLower()

#test only:
#$src = "C:\Users\Bwilliamson\Documents\test\Test source"
#$dest = "C:\Users\Bwilliamson\Documents\test\Test dest"
Write-Host "File backup started."
Write-Host "Source: " $src 
Write-Host "Destination: " $dest
$timestamp = (Get-Date)
if ($uselog) { logwrite "$timestamp Copying from $src to $dest" }
try 
{
    if ($uselog) {& xcopy $src $dest /c /d /e /h /i /k /q /r /s /x /y | out-file $logpath -Append}
    Else
    {xcopy $src $dest /c /d /e /h /i /k /q /r /s /x /y}
}
catch 
{ 
    write-host "Oh no error on copy: " $_ 
    if ($uselog) {logwrite "Oh no error on copy: " $_}
}

Write-Host "File Copy completed."