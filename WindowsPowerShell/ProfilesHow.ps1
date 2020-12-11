#In order to have certain modules built into the powershell session, without remembering the command for them, add them to the powershell profile on the machine.
#There are multiple profiles for each machine and their info can be viewed with the following:
$profile | get-member -type noteproperty | FL Name, Definition
#There isn't always a profile. So to create one, without overwriting any existing use this command in a PowerShell-
if (!(test-path $profile))             {new-item -type file -path $profile -force}
#The output of this command will show where and if a profile was created.