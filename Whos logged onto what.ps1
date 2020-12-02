#    Who's logged onto what
# V3? I think?
# scan all adcomputers and report the user name of each that's online
# aand we're going to scan now for USB drives that are plugged in.
#
# This was original intended for use at a large MSP contract I had. 
# I used it with great success there under the direction of managers that wanted to know who was logged in to what.
# At some point a disgruntled employee was found to be in possession of CUI, so I added a part to this where we scan for USB drives.
# I built this a very long time ago, improvement opportunities here are probably numerous. 
#
# Variables 
import-module activedirectory


$HOMEDRIVE = "C:\"
$HOMEPATH = "Users\" + $env:username

# Set and force overwrite of the $HOME variable
Set-Variable HOME "$HOMEDRIVE$HOMEPATH" -Force

# Set the "~" shortcut value for the FileSystem provider
(get-psprovider 'FileSystem').Home = $HOMEDRIVE + $HOMEPATH

$datecutoff = (Get-Date).AddDays(-30)
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format D)
$ActiveClients = @()
$outfilepath = "$HOME\Documents\"
$outfilename = "$Today -- Who is logged onto what and USB drives.txt" 
$header = "Users that are logged on and their USB drives"
$footer = "`r`n`n$timestamp `r`nActive Users and USBs`r`nPRIVATE`r`n"
#$names = "*WKST*", "*LPTP*"

#Begin filter of AD
write-host "Testing connections to all AD machines that have logged on in the past month"
write-host "To change this - change the DateCutoff variable" -ForegroundColor "Yellow"
$computers = Get-ADComputer -Properties Name, enabled, LastLogonDate, operatingsystem -Filter {OperatingSystem -like "Win*" -and LastLogonDate -gt $datecutoff -and enabled -eq $true } | Where-Object {$_.Name -match "WIN*" -and $_.Name -notmatch "AUTO*"}
#$computers = Get-ADComputer -Properties Name, enabled, LastLogonDate, operatingsystem -Filter {OperatingSystem -like "Win*" -and LastLogonDate -gt $datecutoff -and enabled -eq $true } | where-object {$_.Name -like "Wkst*" -or $_.Name -like "LPTP*"}
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
write-host "`n`nLooking for USB drives on all above AD computers...`n"

$Table = @()
$UserTable = @()
$USBfound = @()
$i = 1
$l = 1
$obj = @(1..200)
$usrobj = @(1..200)
$lowspace =@()

#Some text garbage for the log file. 
$header | out-file -append "$outfilepath$outfilename"
$Content = "`r`nClient computers scanned:...`r`n$outputnames"
$Content | out-file -append "$outfilepath$outfilename"

#Loop and find removable disks (mainly USB)
foreach($client in $ActiveClients)
{
    
    write-host "Looking at.. $client"

    $drives = Get-WmiObject -ComputerName $client Win32_volume | Where-Object {$_.DriveType -eq 2 -and $_.freespace -ne $null} 
    $UN = invoke-command -ComputerName $client -scriptblock {Get-WmiObject -Class Win32_ComputerSystem | %{$_.username}}
    $UN = $UN -replace "shorepowerinc\\",""
    $OS = (Get-WMIObject Win32_OperatingSystem -ComputerName $client).caption
    write-host "User logged in: "$UN 

#Making two tables here, one for user/client then one for the USB objects and some info on them.
    $usrobj[$l] = new-object psobject -Property @{
      ComputerName = $client ;
      Username = $UN ;
      OS = $OS
    }

    $UserTable += $usrobj[$l] 
    $l++


    #using PSobjects to make echo's pretty!
    foreach($drive in $drives)
    {
      if ($drive.driveletter -ne $null)
      {
        $obj[$i] = new-object psobject -Property @{
          ComputerName = $client ;
          Username = $UN ;
          Drive = $drive.Label ;
          Size  = [int]($drive.capacity / 1GB) ;
          Free  = [int]($drive.freespace / 1GB) ;
          PercentFree = [int]($drive.freespace / $drive.capacity * 100) ;
          Path = $drive.driveletter
        }
      
    
    #Add this object to the table....
        $Table += $obj[$i] 
            
        if ($obj[$i].path -ne $null) 
        {
            write-host "`n Removable drive found on $client --- $UN - see report" -ForegroundColor "Yellow"
            $usbfound += $obj[$i] 
            
        }
        $i++
      }
    }
}

#DUMP the tables both to console and file
write-host "'r'n Found USB devices:" -ForegroundColor "yellow"
$usbfound | Sort-object username | FT  -auto
add-content "$outfilepath$outfilename" "`r`nClient and Machine report:`r`n"
$usertable | Sort-object Username | FT  -auto | out-file -append "$outfilepath$outfilename"
#add-content "$outfilepath$outfilename" "`r`nPercentFree report:`r`n"
#$Table | Sort-object PercentFree | FT  -auto | out-file -append "$outfilepath$outfilename"
add-content "$outfilepath$outfilename" "`r`nUSBs By ComputerName report:`r`n"
$Table | Sort-object ComputerName | FT  -auto | out-file -append "$outfilepath$outfilename"

add-content "$outfilepath$outfilename" "`r`n`r`n=====================================================================================`r`n$footer"
write-host "Outfile Appended`n"
write-host "Removable storage found under the following users:`n"
$usbfound | Sort-Object UserName | FT -auto 

write-host "`nDone"
start "$outfilepath$outfilename"