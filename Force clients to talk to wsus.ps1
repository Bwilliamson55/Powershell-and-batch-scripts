#    Force clients to talk to wsus
# V1
# scan all adcomputers that are online and push a command to re-up with wsus
#
# Variables 
import-module activedirectory

$datecutoff = (Get-Date).AddDays(-30)
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format D)
$ActiveClients = @()
$outfilepath = "C:\Users\USER\Desktop\Scripts\Outfiles\"
$outfilename = "$Today -- WSUS clients list.txt" 
$header = "AD computers that were forced to talk to wsus"
$footer = "`r`n`n$timestamp `r`nForced WSUS Clients`r`nPRIVATE`r`n"

#Begin filter of AD
write-host "Testing connections to all AD machines that have logged on in the past month"
write-host "To change this - change the DateCutoff variable" -ForegroundColor "Yellow"
$computers = Get-ADComputer -Properties Name, enabled, LastLogonDate, operatingsystem -Filter {OperatingSystem -like "Win*" -and LastLogonDate -gt $datecutoff -and enabled -eq $true } | where-object {$_.Name -like "Wkst*" -or $_.Name -like "LPTP*"}
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

#Some text garbage for the log file. 
$header | out-file -append "$outfilepath$outfilename"
$Content = "`r`nClient computers scanned:...`r`n$outputnames"
$Content | out-file -append "$outfilepath$outfilename"

#Loop and send wsus resync command
foreach($client in $ActiveClients)
{
    
    write-host "Sending command to.. $client"

    invoke-command -ComputerName $client -scriptblock {wuauclt /resetauthorization /detectnow}

    write-host "Sending GPupdate command to.. $client"

    invoke-command -ComputerName $client -scriptblock {gpupdate /force}
   

}

#DUMP the tables both to console and file
add-content "$outfilepath$outfilename" "`r`nClients sent the wsus command:`r`n"
$Outputnames | out-file -append "$outfilepath$outfilename"

add-content "$outfilepath$outfilename" "`r`n`r`n=====================================================================================`r`n$footer"
write-host "Outfile Appended`n"

write-host "`r`nDone"
start "$outfilepath$outfilename"