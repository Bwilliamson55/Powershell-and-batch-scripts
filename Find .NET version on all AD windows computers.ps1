#Test network PC's for .NET framework versions and sort them neatly

import-module activedirectory

$datecutoff = (Get-Date).AddDays(-30)
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format D)
$outfilepath = "C:\Users\USER\Desktop\Scripts\Outfiles\"
$outfilename = "$Today -- DOT NET Report By Machine.txt" 
$ActiveClients = @()

$ClientList = @()

######################

# Gonna copy pasta the AD scan here to just dump all clients in the list
#Begin filter of AD
write-host "Testing connections to all AD machines that have logged on in the past month"
write-host "To change this - change the DateCutoff variable"
$computers = Get-ADComputer -Properties Name, enabled, LastLogonDate, operatingsystem -Filter {OperatingSystem -like "Win*" -and LastLogonDate -gt $datecutoff -and enabled -eq $true } | where-object {$_.Name -like "Wkst*" -or $_.Name -like "LPTP*" -or $_.Name -like "SRVR*" -or $_.Name -like "GAGE*"}
#$computers = Get-ADComputer -Properties Name, enabled,LastLogonDate -Filter {LastLogonDate -gt $datecutoff -and enabled -eq $true -and OperatingSystem -like "Windows*" -and Name -Like "lptp*"}

#Ping the found computers by name and echo each status
ForEach ($computer in $computers) 
{$client = $Computer.Name
        if (Test-Connection -Computername $client -BufferSize 16 -Count 1 -Quiet) 
        { 
            $ActiveClients += $client 
            write-host "Client " $client " is online."
        }
        else 
        { 
            write-host "Client " $client " is OFFline." 
        }
 ;}


#Echo online clients
$ActiveClients = $ActiveClients | sort
$outputnames = $ActiveClients | out-string
Write-host "`nONLINE Clients`n:"
Write-host $outputnames -ForegroundColor "Yellow" 

#Begin Key testing , echoing to screen when done
write-host "`n`nLooking for .NET on all above AD computers...`n"

$Table = @()

#Loop and find key

foreach($client in $ActiveClients)
{
$NETINFO = ""
write-host "."
write-host "."
    write-host "Looking at .net for $client"
    write-host "."
$NETINFO = invoke-command -ComputerName $client -ScriptBlock{

Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version
    
    }
    $NETINFO | FT PSComputername, PSchildname, Version -auto | out-file -append "$outfilepath$outfilename"
    write-host "Appended File"
}

#DUMP the tables both to console and file
#$Table | Sort-Object Client | FT Client, Value -AutoSize


write-host "`nDone"
start $outfilepath$outfilename