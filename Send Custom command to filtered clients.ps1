#    Force clients to update group policy 
# V3
# scan all adcomputers that are online, use a interactive input to filter clients, and push a scriptblock 
#
# The core of this script I use in a lot of automated management things. 
# The idea of scanning online AD objects before looping through them is not novel, but often useful.
# Change the filters on get-adcomputer for your own purposes.
#
# Variables 
import-module activedirectory

$HOMEDRIVE = "C:\"
$HOMEPATH = "Users\" + $env:username

$datecutoff = (Get-Date).AddDays(-30)
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format D)
$ActiveClients = @()
$FilteredClients = @()
$outfilepath = "$HOMEDRIVE$HOMEPATH\Desktop\Scripts\Outfiles\"
$outfilename = "$Today -- Custom Script pushed to clients- list.txt" 
$header = "AD computers that were force fed a custom scriptblock"
$footer = "`r`n`n$timestamp `r`nForced GP Clients`r`nPRIVATE`r`n"
$Pushyesno = "NO"

#Begin filter of AD

write-host "Testing connections to all AD machines that have logged on in the past month"
write-host "To change this - change the DateCutoff variable" -ForegroundColor "Yellow"
# excluding -or $_.Name -like "SRVR*" from the end of the following get-adcomputer for now...
$computers = Get-ADComputer -Properties Name, enabled, LastLogonDate, operatingsystem -Filter {OperatingSystem -like "Win*" -and LastLogonDate -gt $datecutoff -and enabled -eq $true } | where-object {$_.Name -like "Wkst*" -or $_.Name -like "LPTP*" -or $_.Name -like "SRVR*" }
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

#For re-doing DNS:
#Ipconfig /FlushDNS
#IPconfig /Registerdns

$cmdstring = Read-Host "Enter the command you would like to push"
$scriptblock = [scriptblock]::Create($cmdstring)
$scriptblock

write-host `n "Push $Scriptblock" `n " to these clients?" `n

#Push or not to push. If not then restart scanning.
$Pushyesno = Read-host "Y to run, N to Break`n"
if ($Pushyesno -ne "Y") {
write-host "`n Y was not detected. Exiting script`n"
break
}

#Some text garbage for the log file. 
$header | out-file -append "$outfilepath$outfilename"
$Content = "`r`nClient computers fiddled with:...`r`n$filteredlist"
$Content | out-file -append "$outfilepath$outfilename"

#Loop and send scriptblock
foreach($client in $FilteredClients )
{
    
    #write-host "Sending command to.. $client"

    #invoke-command -ComputerName $client -scriptblock {wuauclt /resetauthorization /detectnow}

    write-host "Sending $scriptblock to.. $client"

    invoke-command -ComputerName $client -scriptblock $Scriptblock
    # invoke-command -ComputerName $client -scriptblock {start-service -Name RemoteRegistry}

}

write-host "NOTE: Outputting to a log file for this script has been DISABLED! `r`n If you would like to change this, uncomment the bottom of the script." -ForegroundColor "yellow"
write-host "`r`n All that would really be written is the following:`r`n"
write-host "`r`nClients sent the following: $scriptblock`r`n"
write-host $FilteredList


<#
#DUMP the tables both to console and file
add-content "$outfilepath$outfilename" "`r`nClients sent the following: $scriptblock `r`n"
$filteredlist | out-file -append "$outfilepath$outfilename"

add-content "$outfilepath$outfilename" "`r`n`r`n=====================================================================================`r`n$footer"
write-host "Outfile Appended`n"

write-host "`r`nDone"
start "$outfilepath$outfilename"

/#>
