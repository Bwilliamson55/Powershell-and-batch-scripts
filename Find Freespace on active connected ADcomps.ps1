#     Drive Usage Report for all machines in AD
#
# Looks at AD computers, filters by loastlogon, enabled T/F, and name (WKST/LPTP/SRVR)
# then ping before issueing commands. Outputs report file in declared directory and opens file when complete
# 
# V3
# Changes:
# Condensed low space reports. Added an array for low space objects
# Not including low space report table, the two tables in teh report are
# ADcomputer disks by freespace, and ADcomputer disks by ComputerName
#
# Variables 
import-module activedirectory

$datecutoff = (Get-Date).AddDays(-30)
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format D)
$ActiveClients = @()
$outfilepath = "C:\Users\USER\Desktop\Scripts\Outfiles\"
$outfilename = "$Today -- Drive Usage Report.txt" 
$header = "Drive Usage Report!"
$footer = "`r`n`n$timestamp `r`nDrive Usage Report`r`nPRIVATE`r`n"

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
$outputnames = $ActiveClients | out-string
Write-host "`nONLINE Clients`n:"
Write-host $outputnames -ForegroundColor "Yellow" 

#Begin Drive testing , echoing to file
write-host "`n`nLooking at free space on all above AD computers logical, local drives...`n"

$Table = @()
$i = 1
$l = 1
$obj = @(1..200)
$lowspace =@()

#Some text garbage for the log file. 
$header | out-file -append "$outfilepath$outfilename"
$Content = "`r`nDrive usage for clients:...`r`n$outputnames"
$Content | out-file -append "$outfilepath$outfilename"

#Loop and find disks of type 3 (local disk, not removable, not network, local.)
foreach($client in $ActiveClients)
{
    
    write-host "Saving info for.. $client"

    $drives = Get-WmiObject -ComputerName $client Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}

    #using PSobjects to make echo's pretty!
    foreach($drive in $drives)
    {
        $obj[$i] = new-object psobject -Property @{
                   ComputerName = $client ;
                   Drive = $drive.DeviceID ;
                   Size  = [int]($drive.size / 1GB) ;
                   Free  = [int]($drive.freespace / 1GB) ;
                   PercentFree = [int]($drive.freespace / $drive.size * 100) 
                   }
    }
    #Add this object to the table....
         $Table += $obj[$i] 
            
        if ($obj[$i].PercentFree -lt 15) 
        {
            write-host "`n Drive space low on $client - see report" -ForegroundColor "Yellow"
            $lowspace += $obj[$i] 
            
        }
        $i++
    }

#DUMP the tables both to console and file
$Table | Sort-object PercentFree | FT  -auto
add-content "$outfilepath$outfilename" "`r`nLow space report:`r`n"
$lowspace | Sort-object PercentFree | FT  -auto | out-file -append "$outfilepath$outfilename"
add-content "$outfilepath$outfilename" "`r`nPercentFree report:`r`n"
$Table | Sort-object PercentFree | FT  -auto | out-file -append "$outfilepath$outfilename"
add-content "$outfilepath$outfilename" "`r`nBy ComputerName report:`r`n"
$Table | Sort-object ComputerName | FT  -auto | out-file -append "$outfilepath$outfilename"
add-content "$outfilepath$outfilename" "`r`n`r`n=====================================================================================`r`n$footer"
write-host "Outfile Appended`n"
write-host "Low space found on the following drives:`n"
$lowspace | Sort-Object PercentFree | FT -auto 

write-host "`nDone"
start "$outfilepath$outfilename"