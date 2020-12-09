#    Force clients to update group policy 
# V1
# scan all adcomputers that are online, use a interactive input to filter clients, and push a command to re-up with GP
#
# Variables 
import-module activedirectory

$datecutoff = (Get-Date).AddDays(-30)
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format D)
$ActiveClients = @()
$FilteredClients = @()
$outfilepath = "C:\Users\USER\Desktop\Scripts\Outfiles\"
$outfilename = "$Today -- GPupdated list.txt" 
$header = "AD computers that were forced to gpupdate"
$footer = "`r`n`n$timestamp `r`nForced GP Clients`r`nPRIVATE`r`n"
$Pushyesno = "NO"

#Begin filter of AD

write-host "Testing connections to all AD machines that have logged on in the past month"
write-host "To change this - change the DateCutoff variable" -ForegroundColor "Yellow"
$computers = Get-ADComputer -Properties Name, enabled, LastLogonDate, operatingsystem -Filter {OperatingSystem -like "Win*" -and LastLogonDate -gt $datecutoff -and enabled -eq $true } | where-object {$_.Name -like "Wkst*" -or $_.Name -like "LPTP*" -or $_.Name -like "SRVR*" -or $_.Name -like "GAGE*"}
#$computers = Get-ADComputer -Properties Name, enabled,LastLogonDate -Filter {LastLogonDate -gt $datecutoff -and enabled -eq $true -and OperatingSystem -like "Windows*" -and Name -Like "lptp*"}

#Ping the found computers by name and echo each status
ForEach ($computer in $computers) 
{$client = $Computer.Name
        if (Test-Connection -Computername $client -BufferSize 16 -Count 1 -Quiet) 
        { 
            $Script:ActiveClients += $client 
            write-host "Client " $client " is online."
        }
        else 
        { 
            write-host "Client " $client " is OFFline." 
        }
 ;}
 
#End function scanandfilter



#Echo online clients
$outputnames = $ActiveClients | out-string 
Write-host "`nONLINE Clients:`n"
Write-host $outputnames -ForegroundColor "Yellow" 

#Filter down clients for pushing commands
write-host "`nPlease Type a string to filter this list. An askerist will not work.`n"
$Filterclientsstring = Read-Host "Enter a String" 
$FilteredClients = $ActiveClients | select-string -pattern $Filterclientsstring 
$FilteredList = $FilteredClients | out-string
#Echo filtered clients
Write-host "`nFiltered Clients:`n"
Write-host $Filteredlist -ForegroundColor "Yellow" 
write-host "`nPush GPupdate /Force to these clients?`n"

#Push or not to push. If not then restart scanning.
$Pushyesno = Read-host "Y to run, N to restart scan/filter`n"
if ($Pushyesno -ne "Y") {
write-host "`n Y was not detected. Exiting script`n"
break
}

#Some text garbage for the log file. 
$header | out-file -append "$outfilepath$outfilename"
$Content = "`r`nClient computers fiddled with:...`r`n$filteredlist"
$Content | out-file -append "$outfilepath$outfilename"

#Loop and send gpupdate command
foreach($client in $FilteredClients )
{
    
    #write-host "Sending command to.. $client"

    #invoke-command -ComputerName $client -scriptblock {wuauclt /resetauthorization /detectnow}

    write-host "Sending GPupdate command to.. $client"

    invoke-command -ComputerName $client -scriptblock {gpupdate /force}
   

}

write-host "NOTE: Outputting to a log file for this script has been DISABLED! `r`n If you would like to change this, uncomment the bottom of the script." -ForegroundColor "yellow"
write-host "`r`n All that would really be written is the following:`r`n"
write-host "`r`nClients sent the GPupdate command:`r`n"
write-host $FilteredList


<#
#DUMP the tables both to console and file
add-content "$outfilepath$outfilename" "`r`nClients sent the GPupdate command:`r`n"
$filteredlist | out-file -append "$outfilepath$outfilename"

add-content "$outfilepath$outfilename" "`r`n`r`n=====================================================================================`r`n$footer"
write-host "Outfile Appended`n"

write-host "`r`nDone"
start "$outfilepath$outfilename"

/#>