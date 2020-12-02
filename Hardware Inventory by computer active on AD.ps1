#     Hardware Report of Client Machines active on AD for Inventory
#
# Looks at AD computers, filters by loastlogon, enabled T/F, and name (WKST/LPTP/SRVR)
# then ping before issueing commands. Outputs report file in declared directory and opens file when complete
# 
# V1
# Changes: Tons. Version - who knows.
#Took a lot of this script from other scripts. So yet another frankenscript. (Work smart)
#
#
# Variables 
import-module activedirectory

$datecutoff = (Get-Date).AddDays(-30)
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format D)
$ActiveClients = @()


$HOMEDRIVE = "C:\"
$HOMEPATH = "Users\" + $env:username
$DESKPATH = $HOMEPATH + "\Desktop"

$outfilepathEACH = $DESKPATH + "\Scripts\Outfiles\perEACH\"
$outfilepath = $DESKPATH + "\Scripts\Outfiles\"
$outfilename = "$Today -- Hardware Report for Inventory.txt" 
$header = "Hardware Report!"
$footer = "`r`n`n$timestamp `r`nHardware Report`r`nPRIVATE`r`n"

############Switch to determine if we want all this in one crappy file, or multiple crappy files.
$title = "Put all reports in one file, or one file per host?"
$message = "Do you want append one file (pick YES) or make a file for each host?(pick NO)"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Appends all hosts details into one big dated file."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Seperate each host into it's own file."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 1) 

switch ($result)
    {
        0 {$APPENDFILE = $True}
        1 {$APPENDFILE = $False}
    }
write-host "Append?"   $APPENDFILE

############################ /switch #######

#Begin filter of AD
write-host "Testing connections to all AD machines that have logged on in the past month"
write-host "To change this - change the DateCutoff variable"
$computers = Get-ADComputer -Properties Name, enabled, LastLogonDate, operatingsystem -Filter {OperatingSystem -like "Win*" -and LastLogonDate -gt $datecutoff -and enabled -eq $true } | where-object {$_.Name -like "Wkst*" -or $_.Name -like "LPTP*" -or $_.Name -like "SRVR*"}
#$computers = Get-ADComputer -Properties Name, enabled,LastLogonDate -Filter {LastLogonDate -gt $datecutoff -and enabled -eq $true -and OperatingSystem -like "Windows*" -and Name -Like "lptp10*"}

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
If ($APPENDFILE)
{
$header | out-file -append "$outfilepath$outfilename"
$Content = "`r`nHardware Inventory For:...`r`n$outputnames"
$Content | out-file -append "$outfilepath$outfilename"
}


# On error the script will continue silently without
$erroractionpreference = "SilentlyContinue"

# TXT file containing the computers being inventoried
#this will actually be a per-script run array.
#$testcomputers = gc -Path "C:\scripts\computers.txt"
$testcomputers = $ActiveClients
<#
### I am blocking this off. Not my work here. I like the progress bar though so I may use that later
#
#
# Looking through the txt file above and counting computer names.
$test_computer_count = $testcomputers.Length;
$x = 0;

write-host -foregroundcolor cyan ""
write-host -foregroundcolor cyan "Testing $test_computer_count computers, this may take a while."

foreach ($computer in $testcomputers) {
        # I only send 2 echo requests to speed things up, if you want the defaut 4
        # delete the -count 2 portion
   if (Test-Connection -ComputerName $computer -Quiet -count 2){
        # The path to the livePCs.txt file, change to meet your needs
        Add-Content -value $computer -path c:\scripts\livePCs.txt
        }else{
        # The path to the deadPCs.txt file, change to meet your needs
        Add-Content -value $computer -path c:\scripts\deadPCs.txt
        }
    $testcomputer_progress = [int][Math]::Ceiling((($x / $test_computer_count) * 100))
    # Progress bar
    Write-Progress  "Testing Connections" -PercentComplete $testcomputer_progress -Status "Percent Complete - $testcomputer_progress%" -Id 1;
    Sleep(1);
    $x++;

}

write-host -foregroundcolor cyan ""
write-host -foregroundcolor cyan "Testing Connection complete"
write-host -foregroundcolor cyan ""
#
#
#>

$ComputerName = $ActiveClients

$computer_count = $ComputerName.Length;
# The results of the script are here
$exportLocation = $outfilepath
$exportLocation += $outfilename
$exportlocation
$i = 0;
foreach ($Computer in $ComputerName){
  Write-host "looking at $computer"
  $Bios =get-wmiobject win32_bios -Computername $Computer
  $Hardware = get-wmiobject Win32_computerSystem -Computername $Computer
    $Mainboard = get-wmiobject Win32_BaseBoard -Computername $Computer
  $Sysbuild = get-wmiobject Win32_WmiSetting -Computername $Computer
  $OS = gwmi Win32_OperatingSystem -Computername $Computer
    $GPU = get-wmiobject Win32_VideoController -computername $computer
  $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer | ? {$_.IPEnabled}
  $driveSpace = gwmi win32_volume -computername $Computer -Filter 'drivetype = 3' |
  select PScomputerName, driveletter, label, @{LABEL='GBfreespace';EXPRESSION={"{0:N2}" -f($_.freespace/1GB)} } |
  Where-Object { $_.driveletter -match "C:" }
  $cpu = Get-WmiObject Win32_Processor  -computername $computer
  $username = Get-ChildItem "\\$computer\c$\Users" | Sort-Object LastWriteTime -Descending | Select Name, LastWriteTime -first 1
  $totalMemory = [math]::round($Hardware.TotalPhysicalMemory/1024/1024/1024, 2)
  $lastBoot = $OS.ConvertToDateTime($OS.LastBootUpTime)

#write-host -foregroundcolor yellow "Found $computer"
   $computer_progress = [int][Math]::Ceiling((($i / $computer_count) * 100))
    # Progress bar
    Write-Progress  "Gathering Hardware Info" -PercentComplete $computer_progress -Status "Percent Complete - $computer_progress%" -Id 1;
    Sleep(1);
    $i++;
  ######

  $systemBios = $Bios.serialnumber
  $OutputObj  = New-Object -Type PSObject
  $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
  $OutputObj | Add-Member -MemberType NoteProperty -Name Manufacturer -Value $Hardware.Manufacturer
  $OutputObj | Add-Member -MemberType NoteProperty -Name Model -Value $Hardware.Model
  $OutputObj | Add-Member -MemberType NoteProperty -Name Mobo_Manufacturer -Value $Mainboard.Manufacturer
  $OutputObj | Add-Member -MemberType NoteProperty -Name Mobo_Serial -Value $Mainboard.SerialNumber
  $OutputObj | Add-Member -MemberType NoteProperty -Name Mobo_Product -Value $Mainboard.Product
  $OutputObj | Add-Member -MemberType NoteProperty -Name CPU_Info -Value $cpu.Name
  $OutputObj | Add-Member -MemberType NoteProperty -Name SystemType -Value $Hardware.SystemType
  $OutputObj | Add-Member -MemberType NoteProperty -Name BuildVersion -Value $SysBuild.BuildVersion
  $OutputObj | Add-Member -MemberType NoteProperty -Name OS -Value $OS.Caption
  $OutputObj | Add-Member -MemberType NoteProperty -Name SPVersion -Value $OS.csdversion
  $OutputObj | Add-Member -MemberType NoteProperty -Name BiosName -Value $Bios.Name
  $OutputObj | Add-Member -MemberType NoteProperty -Name BiosManufacturer -Value $Bios.Manufacturer
  $OutputObj | Add-Member -MemberType NoteProperty -Name SMBiosVersion -Value $Bios.SMBIOSBIOSVersion
  $OutputObj | Add-Member -MemberType NoteProperty -Name BiosVersion -Value $Bios.Version
  $OutputObj | Add-Member -MemberType NoteProperty -Name BiosSerialNumber -Value $systemBios
  Foreach ($Card in $GPU)
    {
              $OutputObj | Add-Member -MemberType NoteProperty -Name "$($Card.DeviceID)_Name" -Value $Card.Name
              $OutputObj | Add-Member -MemberType NoteProperty -Name "$($Card.DeviceID)_Processor" -Value $Card.VideoProcessor
              $OutputObj | Add-Member -MemberType NoteProperty -Name "$($Card.DeviceID)_DriverVersion" -Value $Card.DriverVersion
    }
    foreach ($Network in $Networks) 
    {
    $OutputObj | Add-Member -MemberType NoteProperty -Name "NIC_Index_$($Network.Index)_IPAddress" -Value $Network.IPAddress
    $OutputObj | Add-Member -MemberType NoteProperty -Name "NIC_Index_$($Network.Index)_MACAddress" -Value $Network.MACAddress
    $OutputObj | Add-Member -MemberType NoteProperty -Name "NIC_Index_$($Network.Index)_Description" -Value $Network.Description
    }
    $OutputObj | Add-Member -MemberType NoteProperty -Name UserName -Value $username.Name
    #$OutputObj | Add-Member -MemberType NoteProperty -Name Last-Login -Value $username.LastWriteTime
    $OutputObj | Add-Member -MemberType NoteProperty -Name C:_GBfreeSpace -Value $driveSpace.GBfreespace
    $OutputObj | Add-Member -MemberType NoteProperty -Name Total_Physical_Memory -Value $totalMemory
    #$OutputObj | Add-Member -MemberType NoteProperty -Name Last_Reboot -Value $lastboot
    #$outputobj
    #$OutputObj | Export-Csv $exportLocation -Append
    If ($APPENDFILE) {
    $OutputObj | Out-file $exportLocation -Append
    write-host "APPEND"
    $APPENDFILE
    }
    else
    {
    write-host "Seperate file!"
    $exportLocation = $outfilepathEACH
    $exportLocation += $computer + "  "
    $exportLocation += $outfilename
    $OutputObj | Out-file $exportLocation
    }
}

write-host -foregroundcolor cyan "Script is complete, the results are here: $exportLocation"

write-host "`nDone"
If ($APPENDFILE)
{
  start "$outfilepath$outfilename"
}
Else
{
  start "$outfilepatheach"
}