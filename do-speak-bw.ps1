Function Do-Speak {
 
[CmdletBinding()]
 
param
(
 
[Parameter(Position=0)]
 
$Computer,

[Parameter(Position=1)]
 
$msg
 
)
 
If (!$computer)
 
{
 
$Text=Read-Host 'Enter Text'
 
[Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
$object = New-Object System.Speech.Synthesis.SpeechSynthesizer
$object.Speak($Text)
 
} elseif ($msg) {
$User = "bwilliamson"
$File = "C:\temp\Password.txt"
$cred=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
#$cred=Get-Credential
 
$PS=New-PSSession -ComputerName $Computer -Credential $cred
 
Invoke-Command -Session $PS {
$Text=$msg
 
[Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
$object = New-Object System.Speech.Synthesis.SpeechSynthesizer
$object.Speak($Text)
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