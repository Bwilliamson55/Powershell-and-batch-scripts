$sysfunctions = gci function:
Function Get-Software  {

  [OutputType('System.Software.Inventory')]

  [Cmdletbinding()] 

  Param( 

  [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 

  [String[]]$Computername=$env:COMPUTERNAME

  )         

  Begin {

  }

  Process  {     

  ForEach  ($Computer in  $Computername){ 

  If  (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {

  $Paths  = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         

  ForEach($Path in $Paths) { 

  Write-Verbose  "Checking Path: $Path"

  #  Create an instance of the Registry Object and open the HKLM base key 

  Try  { 

  $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Computer,'Registry64') 

  } Catch  { 

  Write-Error $_ 

  Continue 

  } 

  #  Drill down into the Uninstall key using the OpenSubKey Method 

  Try  {

  $regkey=$reg.OpenSubKey($Path)  

  # Retrieve an array of string that contain all the subkey names 

  $subkeys=$regkey.GetSubKeyNames()      

  # Open each Subkey and use GetValue Method to return the required  values for each 

  ForEach ($key in $subkeys){   

  Write-Verbose "Key: $Key"

  $thisKey=$Path+"\\"+$key 

  Try {  

  $thisSubKey=$reg.OpenSubKey($thisKey)   

  # Prevent Objects with empty DisplayName 

  $DisplayName =  $thisSubKey.getValue("DisplayName")

  If ($DisplayName  -AND $DisplayName  -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {

  $Date = $thisSubKey.GetValue('InstallDate')

  If ($Date) {

  Try {

  $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)

  } Catch{

  Write-Warning "$($Computer): $_ <$($Date)>"

  $Date = $Null

  }

  } 

  # Create New Object with empty Properties 

  $Publisher =  Try {

  $thisSubKey.GetValue('Publisher').Trim()

  } 

  Catch {

  $thisSubKey.GetValue('Publisher')

  }

  $Version = Try {

  #Some weirdness with trailing [char]0 on some strings

  $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))

  } 

  Catch {

  $thisSubKey.GetValue('DisplayVersion')

  }

  $UninstallString =  Try {

  $thisSubKey.GetValue('UninstallString').Trim()

  } 

  Catch {

  $thisSubKey.GetValue('UninstallString')

  }

  $InstallLocation =  Try {

  $thisSubKey.GetValue('InstallLocation').Trim()

  } 

  Catch {

  $thisSubKey.GetValue('InstallLocation')

  }

  $InstallSource =  Try {

  $thisSubKey.GetValue('InstallSource').Trim()

  } 

  Catch {

  $thisSubKey.GetValue('InstallSource')

  }

  $HelpLink = Try {

  $thisSubKey.GetValue('HelpLink').Trim()

  } 

  Catch {

  $thisSubKey.GetValue('HelpLink')

  }

  $Object = [pscustomobject]@{

  Computername = $Computer

  DisplayName = $DisplayName

  Version  = $Version

  InstallDate = $Date

  Publisher = $Publisher

  UninstallString = $UninstallString

  InstallLocation = $InstallLocation

  InstallSource  = $InstallSource

  HelpLink = $thisSubKey.GetValue('HelpLink')

  EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize')*1024)/1MB,2))

  }

  $Object.pstypenames.insert(0,'System.Software.Inventory')

  Write-Output $Object

  }

  } Catch {

  Write-Warning "$Key : $_"

  }   

  }

  } Catch  {}   

  $reg.Close() 

  }                  

  } Else  {

  Write-Error  "$($Computer): unable to reach remote system!"

  }

  } 

  } 

}  

Function Send-Msg {

[CmdletBinding()]
 
param
(
 
[Parameter(Position=0)]
 
$Computer,

[Parameter(Position=1)]
 
$Msg
 
)

If (!$Computer)
 
{
Write-Host "`r`nThis will prompt for a computer name, then a message to send via popup window to that computer." -ForegroundColor Yellow
Write-Host "`rYour username and a timestamp will be displayed on the popup window`r" -ForegroundColor Red
$name = read-host "Enter target computer name "
$msg = read-host "Enter your message "
Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $name
} elseif ($Msg) {
Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $Computer
}
}


Function Get-Goat {
    $URI = "http://www.heldeus.nl/goat/GoatFarming.html"
    $HTML = Invoke-WebRequest -Uri $URI
    Write-Host "Why Goatfarming is better than IT: " -NoNewline
    ($HTML.ParsedHtml.getElementsByTagName("p") | Where { $_.className -eq "goat" } ).innerText | Get-Random
    Write-Host ""
} 
Function Get-Bash {
    $URI = "http://www.bash.org/?random"
    $HTML = Invoke-WebRequest -Uri $URI
    write-host "Here's a Bash quote: "
    ($html.ParsedHtml.getElementsByTagName("p") | ? {$_.classname -eq "qt"}).innertext | get-random
    } 
Function Get-Jargon {
    $URI = "http://www.catb.org/jargon/html/go01.html"
    $HTML = Invoke-WebRequest -Uri $URI
    $links = @()

    #Grab a random link, that contains a / and dig into it:
    $Links = $HTML.links | where {$_.href -like '*/*'} | select href
    $chosenlink = $links | get-random | select href -ExpandProperty href

    $digURI = "http://www.catb.org/jargon/html/$chosenlink"
    $digHTML = Invoke-WebRequest -Uri $digURI

    $Title = $digHTML.ParsedHtml.getelementsbytagname("dt") | where {$_.id} | select id -ExpandProperty id
    $Body = @()
    $Body = $digHTML.ParsedHtml.getelementsbytagname("p") | select innertext -ExpandProperty innertext
    $Body = $body -join "`r`n`r`n" | out-string
    
    #Lets make this output pretty!
    Write-Host "`nYour jargon of the day:`n`r" -fore yellow
    (Get-Culture).textinfo.ToTitleCase($title)
    write-host ""
    $Body
    Write-Host ""
    Write-Host "You're Jargon for the day provided by:`r`n" -fore Yellow
    $digURI
} 
Function Get-Song {
#Randomly picked Choices:
# 1 The Imperial March (Star Wars)
# 2 Mission Impossible
# 3 Tetris
# 4 Mario
$Choices = '[console]::beep(440,500);[console]::beep(440,500);[console]::beep(440,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,1000);[console]::beep(659,500);[console]::beep(659,500);[console]::beep(659,500);[console]::beep(698,350);[console]::beep(523,150);[console]::beep(415,500);[console]::beep(349,350);[console]::beep(523,150);[console]::beep(440,1000)',
'[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(932,150);Start-Sleep -m 150;[console]::beep(1047,150);Start-Sleep -m 150;[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(699,150);Start-Sleep -m 150;[console]::beep(740,150);Start-Sleep -m 150;[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(932,150);Start-Sleep -m 150;[console]::beep(1047,150);Start-Sleep -m 150;[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(784,150);Start-Sleep -m 300;[console]::beep(699,150);Start-Sleep -m 150;[console]::beep(740,150);Start-Sleep -m 150;[console]::beep(932,150);[console]::beep(784,150);[console]::beep(587,1200);Start-Sleep -m 75;[console]::beep(932,150);[console]::beep(784,150);[console]::beep(554,1200);Start-Sleep -m 7;[console]::beep(932,150);[console]::beep(784,150);[console]::beep(523,1200);Start-Sleep -m 150;[console]::beep(466,150);[console]::beep(523,150)',
'[console]::Beep(658, 125);[console]::Beep(1320, 500);[console]::Beep(990, 250);[console]::Beep(1056, 250);[console]::Beep(1188, 250);[console]::Beep(1320, 125);[console]::Beep(1188, 125);[console]::Beep(1056, 250);[console]::Beep(990, 250);[console]::Beep(880, 500);[console]::Beep(880, 250);[console]::Beep(1056, 250);[console]::Beep(1320, 500);[console]::Beep(1188, 250);[console]::Beep(1056, 250);[console]::Beep(990, 750);[console]::Beep(1056, 250);[console]::Beep(1188, 500);[console]::Beep(1320, 500);[console]::Beep(1056, 500);[console]::Beep(880, 500);[console]::Beep(880, 500);Start-Sleep -m 250;[console]::Beep(1188, 500);[console]::Beep(1408, 250);[console]::Beep(1760, 500);[console]::Beep(1584, 250);[console]::Beep(1408, 250);[console]::Beep(1320, 750);[console]::Beep(1056, 250);[console]::Beep(1320, 500);[console]::Beep(1188, 250);[console]::Beep(1056, 250);[console]::Beep(990, 500);[console]::Beep(990, 250);[console]::Beep(1056, 250);[console]::Beep(1188, 500);[console]::Beep(1320, 500);[console]::Beep(1056, 500);[console]::Beep(880, 500);[console]::Beep(880, 500);Start-Sleep -m 500;[console]::Beep(1320, 500);[console]::Beep(990, 250);[console]::Beep(1056, 250);[console]::Beep(1188, 250);[console]::Beep(1320, 125);[console]::Beep(1188, 125);[console]::Beep(1056, 250);[console]::Beep(990, 250);[console]::Beep(880, 500);[console]::Beep(880, 250);[console]::Beep(1056, 250);[console]::Beep(1320, 500);[console]::Beep(1188, 250);[console]::Beep(1056, 250);[console]::Beep(990, 750);[console]::Beep(1056, 250);[console]::Beep(1188, 500);[console]::Beep(1320, 500);[console]::Beep(1056, 500);[console]::Beep(880, 500);[console]::Beep(880, 500);Start-Sleep -m 250;[console]::Beep(1188, 500);[console]::Beep(1408, 250);[console]::Beep(1760, 500);[console]::Beep(1584, 250);[console]::Beep(1408, 250);[console]::Beep(1320, 750);[console]::Beep(1056, 250);[console]::Beep(1320, 500);[console]::Beep(1188, 250);[console]::Beep(1056, 250);[console]::Beep(990, 500);[console]::Beep(990, 250);[console]::Beep(1056, 250);[console]::Beep(1188, 500);[console]::Beep(1320, 500);[console]::Beep(1056, 500);[console]::Beep(880, 500);[console]::Beep(880, 500);Start-Sleep -m 500;[console]::Beep(660, 1000);[console]::Beep(528, 1000);[console]::Beep(594, 1000);[console]::Beep(495, 1000);[console]::Beep(528, 1000);[console]::Beep(440, 1000);[console]::Beep(419, 1000);[console]::Beep(495, 1000);[console]::Beep(660, 1000);[console]::Beep(528, 1000);[console]::Beep(594, 1000);[console]::Beep(495, 1000);[console]::Beep(528, 500);[console]::Beep(660, 500);[console]::Beep(880, 1000);[console]::Beep(838, 2000);[console]::Beep(660, 1000);[console]::Beep(528, 1000);[console]::Beep(594, 1000);[console]::Beep(495, 1000);[console]::Beep(528, 1000);[console]::Beep(440, 1000);[console]::Beep(419, 1000);[console]::Beep(495, 1000);[console]::Beep(660, 1000);[console]::Beep(528, 1000);[console]::Beep(594, 1000);[console]::Beep(495, 1000);[console]::Beep(528, 500);[console]::Beep(660, 500);[console]::Beep(880, 1000);[console]::Beep(838, 2000)',
'[console]::Beep(659, 125); [console]::Beep(659, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 167; [console]::Beep(523, 125); [console]::Beep(659, 125); Start-Sleep -m 125; [console]::Beep(784, 125); Start-Sleep -m 375; [console]::Beep(392, 125); Start-Sleep -m 375; [console]::Beep(523, 125); Start-Sleep -m 250; [console]::Beep(392, 125); Start-Sleep -m 250; [console]::Beep(330, 125); Start-Sleep -m 250; [console]::Beep(440, 125); Start-Sleep -m 125; [console]::Beep(494, 125); Start-Sleep -m 125; [console]::Beep(466, 125); Start-Sleep -m 42; [console]::Beep(440, 125); Start-Sleep -m 125; [console]::Beep(392, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 125; [console]::Beep(784, 125); Start-Sleep -m 125; [console]::Beep(880, 125); Start-Sleep -m 125; [console]::Beep(698, 125); [console]::Beep(784, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 125; [console]::Beep(523, 125); Start-Sleep -m 125; [console]::Beep(587, 125); [console]::Beep(494, 125); Start-Sleep -m 125; [console]::Beep(523, 125); Start-Sleep -m 250; [console]::Beep(392, 125); Start-Sleep -m 250; [console]::Beep(330, 125); Start-Sleep -m 250; [console]::Beep(440, 125); Start-Sleep -m 125; [console]::Beep(494, 125); Start-Sleep -m 125; [console]::Beep(466, 125); Start-Sleep -m 42; [console]::Beep(440, 125); Start-Sleep -m 125; [console]::Beep(392, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 125; [console]::Beep(784, 125); Start-Sleep -m 125; [console]::Beep(880, 125); Start-Sleep -m 125; [console]::Beep(698, 125); [console]::Beep(784, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 125; [console]::Beep(523, 125); Start-Sleep -m 125; [console]::Beep(587, 125); [console]::Beep(494, 125); Start-Sleep -m 375; [console]::Beep(784, 125); [console]::Beep(740, 125); [console]::Beep(698, 125); Start-Sleep -m 42; [console]::Beep(622, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 167; [console]::Beep(415, 125); [console]::Beep(440, 125); [console]::Beep(523, 125); Start-Sleep -m 125; [console]::Beep(440, 125); [console]::Beep(523, 125); [console]::Beep(587, 125); Start-Sleep -m 250; [console]::Beep(784, 125); [console]::Beep(740, 125); [console]::Beep(698, 125); Start-Sleep -m 42; [console]::Beep(622, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 167; [console]::Beep(698, 125); Start-Sleep -m 125; [console]::Beep(698, 125); [console]::Beep(698, 125); Start-Sleep -m 625; [console]::Beep(784, 125); [console]::Beep(740, 125); [console]::Beep(698, 125); Start-Sleep -m 42; [console]::Beep(622, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 167; [console]::Beep(415, 125); [console]::Beep(440, 125); [console]::Beep(523, 125); Start-Sleep -m 125; [console]::Beep(440, 125); [console]::Beep(523, 125); [console]::Beep(587, 125); Start-Sleep -m 250; [console]::Beep(622, 125); Start-Sleep -m 250; [console]::Beep(587, 125); Start-Sleep -m 250; [console]::Beep(523, 125); Start-Sleep -m 1125; [console]::Beep(784, 125); [console]::Beep(740, 125); [console]::Beep(698, 125); Start-Sleep -m 42; [console]::Beep(622, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 167; [console]::Beep(415, 125); [console]::Beep(440, 125); [console]::Beep(523, 125); Start-Sleep -m 125; [console]::Beep(440, 125); [console]::Beep(523, 125); [console]::Beep(587, 125); Start-Sleep -m 250; [console]::Beep(784, 125); [console]::Beep(740, 125); [console]::Beep(698, 125); Start-Sleep -m 42; [console]::Beep(622, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 167; [console]::Beep(698, 125); Start-Sleep -m 125; [console]::Beep(698, 125); [console]::Beep(698, 125); Start-Sleep -m 625; [console]::Beep(784, 125); [console]::Beep(740, 125); [console]::Beep(698, 125); Start-Sleep -m 42; [console]::Beep(622, 125); Start-Sleep -m 125; [console]::Beep(659, 125); Start-Sleep -m 167; [console]::Beep(415, 125); [console]::Beep(440, 125); [console]::Beep(523, 125); Start-Sleep -m 125; [console]::Beep(440, 125); [console]::Beep(523, 125); [console]::Beep(587, 125); Start-Sleep -m 250; [console]::Beep(622, 125); Start-Sleep -m 250; [console]::Beep(587, 125); Start-Sleep -m 250; [console]::Beep(523, 125);'
$play = $Choices[(Get-Random -Maximum ([array]$Choices).count)]
iex $play
}
Function Do-Speak {
 
[CmdletBinding()]
 
param
(
 
[Parameter(Position=0)]
 
$Computer,

[Parameter(Position=1)]
 
$Text
 
)
 
If (!$computer)
 
{
 
$Text=Read-Host 'Enter Text'
 
[Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
$object = New-Object System.Speech.Synthesis.SpeechSynthesizer
$object.Speak($Text)
 
} elseif ($Text) {

$User = "bwilliamson"
$File = "C:\temp\Password.txt"
$cred=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
#$cred=Get-Credential
 
$PS=New-PSSession -ComputerName $Computer -Credential $cred
 
Invoke-Command -Session $PS {
 
[Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
$object = New-Object System.Speech.Synthesis.SpeechSynthesizer
$object.Speak($using:Text)
}
} else {
$User = "bwilliamson"
$File = "C:\temp\Password.txt"
$cred=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
#$cred=Get-Credential
 
$PS=New-PSSession -ComputerName $Computer -Credential $cred
 
Invoke-Command -Session $PS {
$Text=Read-Host 'Enter Text'
 
[Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
$object = New-Object System.Speech.Synthesis.SpeechSynthesizer
$object.Speak($Text)
}
 
}

}

Function Get-Monitors {
[CmdletBinding()]
 
param
(
 
[Parameter(Position=0)]
 
$hostname
 
)

Function ConvertTo-Char
(	
	$Array
)
{
	$Output = ""
	ForEach($char in $Array)
	{	$Output += [char]$char -join ""
	}
	return $Output
}

$Query = Get-WmiObject -comp $hostname -Query "Select * FROM WMIMonitorID" -Namespace root\wmi

$Results = ForEach ($Monitor in $Query)
{    
	New-Object PSObject -Property @{
		ComputerName = $hostname
		Active = $Monitor.Active
		Manufacturer = ConvertTo-Char($Monitor.ManufacturerName)
		UserFriendlyName = ConvertTo-Char($Monitor.userfriendlyname)
		SerialNumber = ConvertTo-Char($Monitor.serialnumberid)
		WeekOfManufacture = $Monitor.WeekOfManufacture
		YearOfManufacture = $Monitor.WeekOfManufacture
	}
}

$Results | Select ComputerName,Active,Manufacturer,UserFriendlyName,SerialNumber,WeekOfManufacture,YearOfManufacture﻿
}

Import-Module C:\Users\bwilliamson\Documents\WindowsPowerShell\Scripts\UninstallHotFixWin10.psm1
# directory where my scripts are stored

$psdir="C:\Users\bwilliamson\Documents\WindowsPowerShell\Scripts"  

# load all 'autoload' scripts

Get-ChildItem "${psdir}\*.ps1" | %{.$_ ; write-host "$_.name Loaded"} 
import-module activedirectory
Import-Module PowerShell-Beautifier.psd1
Write-host "Active-Directory Cmdlets loaded"
Write-Host "Custom PowerShell Environment Loaded" -fore yellow
Write-Host "Custom Functions Loaded:" -fore green
gci function: | where {$sysfunctions -notcontains $_}
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
