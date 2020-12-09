import-module activedirectory

$datecutoff = (Get-Date).AddDays(-365)

Write-Host "These are the AD computers that have not logged on in 365 days or more" "`n"

Get-ADComputer -Properties LastLogonDate, name, enabled -Filter {LastLogonDate -lt $datecutoff} | sort Name | FT Name, LastlogonDate, Enabled -autosize

$title = "Disable These Machines?"
$message = "Do you want to disable all these machines in AD?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Disables All Machine AD objects Listed Above."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Exit."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 1) 

switch ($result)
    {
        0 {Get-ADComputer -Properties LastLogonDate -Filter {LastLogonDate -lt $datecutoff} | Set-ADComputer -Enabled $false}
        1 {Return}
    }