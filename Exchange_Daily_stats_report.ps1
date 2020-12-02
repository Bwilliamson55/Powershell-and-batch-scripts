###############
#
# Exchange Report V3
#
# Hopefully this will be the last revision. I'm going to strip commented out code that will probably not be used.
# Also I will be re-formatting the Tables so they're all at the same level.
# If you're looking for older code revisions, look back at V2 or V1
#
#
#I currently use this as a scheduled task on our reporting server, to present daily sent/recieved stats on sales personel. 
#You quickly see who's working and who's not, if their day-to-day involves a lot of email.
#
#If you plan on using this for a schuled task- the action part of that is what tripped me up. So you need to start a program-
#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe (NO QUOTES) with the following arguments-
#-NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "C:\Reports\Powershell reports\Exchange_Daily_stats_report.ps1"
#
# TODO: Fix source and eventid filters. This mostly works, but I've found that pulling log rows with 'deliver' as the eventid is not enough.
# It's close, but not exact. 
# Source needs to be 'storedriver' and events work like this - 'Receive' = a mail sent, 'deliver' = a mail received
# More info: https://docs.microsoft.com/en-us/powershell/module/exchange/get-messagetrackinglog?view=exchange-ps
# https://docs.microsoft.com/en-us/exchange/mail-flow/transport-logs/message-tracking?view=exchserver-2019


#generate a secure password file, this is a one time one liner that MUST be run if you want this to work
#read-host -assecurestring | convertfrom-securestring | out-file C:\temp\mysecurestring.txt

#You'll need to put your domain in here.
$username = "domain\administrator"
$password = Get-Content 'C:\temp\mysecurestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password

#Connect to the Exchange Server using the secure cred above
#############Use your own exchange info for this uri
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ExchangeServer.Domain.local/PowerShell/ -Authentication Kerberos -Credential $cred

Import-PSSession $Session

#DONT FORGET TO DISCONNECT WITH..
# Remove-pssession $session

#Some vars. Outfilename was used in this one. I'm going for an HTML report due to the amount of hash tables.
write-host "Assigning Variables..."
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format HHmmtt)
$outfilepath = "C:\Reports\Powershell reports\"
$outfilename = "$Today-$timestamp -- EmailReport.html"
#Get todays date twice
$startDate=Get-Date
$endDate=Get-Date
#Subtract 1 day from todays date (report ending day) and 30 days from todays date (report starting day)
$startDateFormatted=$startDate.AddDays(-30).ToShortDateString()
$endDateFormatted=$endDate.AddDays(-1).ToShortDateString()

$ReportTitle = 
@"
Mailbox Stats `r`n
Report date range: $startDateFormatted 00:00:00 - $endDateFormatted 23:59:59 
`r`n `r`n
"@

#Mailboxs to gather stats on, we could make this more dynamic down the road. e.g. pull in a csv or txt file.
###Put in your own user's you want to track, of course.
$mailbox= 'worker1@domain.com','worker2@domain.com','worker3@domain.com'
Write-host " `r`n Mailboxes to be scanned- $mailbox"

#Hash tables for send and receive counts
$Sent = @{}
$Received = @{}
#$All = @{}

# Initialize allmail, I have it as an array but I don't think it matters.
$AllMail = @()
write-host " `r`n Arrays and hashes initialized.."
write-host "`r`n Scanning Exchange logs, please be patient. This is going through thousands of records"
#This is the exchange query part. I have a pipeline progress bar I might use here. Calling on the past 15+ days can take time sometimes.
Foreach ($Addr in $mailbox)
{
  $AllMail += (Get-MessageTrackingLog -Start "$startDateFormatted 00:00:00" -End "$endDateFormatted 23:59:59" -EventID Deliver -ResultSize Unlimited | ? {$_.sender -contains $Addr -or $_.recipients -contains $Addr})
} 

#Ok this is the Engine of the script. Using the junk drawer- $Allmail, we're going to change the date format, distil it to just counts by day for sent and received.
#Dump those results into hash tables, do a little more sorting because it doesn't want to stick. Then shove those hashes' into dynamically named hashes to be called 
#during the email part of the script at the bottom.
write-host "`r`n Logs scanned and filtered, Beginning processing of Logs.."
Foreach ($Addr in $mailbox){

Write-Host $Addr

#Get sent from addr
$TS = $Allmail | Select @{E={Get-Date $_.Timestamp -Format 'MM/dd/yyyy'};Label="Date";}, Sender, Recipients | ? {$_.sender -contains $Addr} | Group Date | Sort Date -Descending  | Select @{E={$_.Count};Label="Sent";}, @{E={$_.Name};Label="Date";}
#get rcvd from addr
$TR = $Allmail | Select @{E={Get-Date $_.Timestamp -Format 'MM/dd/yyyy'};Label="Date";}, Sender, Recipients | ? {$_.recipients -contains $Addr} | Group Date | Sort Date -Descending  | Select @{E={$_.Count};Label="Received";}, @{E={$_.Name};Label="Date";}

#Drop those hash bombs
#SENT
write-host "Doing TS for $addr"
$hashs = @{}
$TS | Sort Name -Descending | %{$hashs[$_.Date] = $_.Sent}
$hashs = $hashs.GetEnumerator() | Sort Name 
$hashs = $hashs | Select @{E={$_.value};Label="Sent";}, @{E={$_.name};Label="Date";} |Sort Date -Descending

#Dump the hash into dynamicly named hash
New-variable "Sent-$addr" -value $hashs
#Example of how to call this value back (And make it html): (get-variable -name ("Sent-" + $addr) -ValueOnly) | convertto-html -fragment

#RECEIVED
write-host "Doing TR for $addr"
$hashr = @{}
$TR | Sort Name -Descending | %{$hashr[$_.Date] = $_.Received}
$hashr = $hashr.GetEnumerator() | Sort Name 
$hashr = $hashr | Select @{E={$_.value};Label="Received";}, @{E={$_.name};Label="Date";} |Sort Date -Descending

#Dump the hash into dynamicly named hash
New-variable "Rec-$addr" -value $hashr

}

#########This was modified a bit from the original, to pipe in Allmail, rather than do a query.
$AllMail | foreach {
    if ($mailbox -contains $_.sender )
      { $Sent[$_.Sender]++ }

    foreach ($Recipient in $_.Recipients)
    {
      if ($mailbox -contains $Recipient )
      { $Received[$Recipient]++ }
    }
}

#Use the first query data to get an overall count
$Overall = 
$Mailbox | 
foreach {
$ResultHash = 
@{
    Address = $_
    Sent    = $Sent[$_]
    Received = $Received[$_]
}

New-Object -TypeName PSObject -Property $ResultHash |
  Select Address,Sent,Received
}

#
#
#Email Time! I'll try to keep all html below here.
#
#

write-host "`r`n Email Time. If the code block to save as html as well is un-commented, the HTML file should be generated now."

$header = @"
<Title>$ReportTitle</Title>
<style type="text/css">
body { background-color:#FFFFFF;
font-family:Tahoma;
font-size:12pt; }
td, th { border:1px solid black;
border-collapse:collapse; }
th { color:black;
background-color:#6495ED; }
table, tr, td, th { padding: 4px; margin: 0px }
table { display: inline-block;margin-left:5px; margin-bottom:20px;}
</style>
<br>
<H3>$ReportTitle</H3>
"@


#Lets make the body of the document.
#I WOULD make the master html object xml, because it's easier to walk it's nodes, BUT you can't just += with xml objects. Boo.
[string]$html=""
$html = $Overall | convertto-html -fragment
$html+="<hr><br>"

#These tables look gawd aweful in outlook. Outlook WILL NOT play nice with HTML tables. 
#If you look closely you'll see I put the Sent/Recieved tables in cells of another table
#JUST so outlook would put them side by side. Thanks outlook. 

Foreach ($addr in $mailbox)
{
$html+='<table class="father">'
$html+="<tr><th colspan='2'><H4>$addr Statistics</H4></th></tr>"
$html+='<td valign="top"; style="Border:none" !important; >'
$html+=(get-variable -name ("Sent-" + $addr) -ValueOnly) | convertto-html -fragment
$html+='</td><td valign="top"; style="Border:none" !important; >'
$html+=(get-variable -name ("Rec-" + $addr) -ValueOnly) | convertto-html -fragment
$html+="</td></tr>"
$html+="</table>"
}

#Dump to a htm file if you want- just uncomment the next two lines. This won't interfere with the email.
ConvertTo-HTML -Head $header -Body $html -PostContent “<h6>Created $(Get-Date)</h6>” |
Out-File -filepath "$outfilepath$outfilename"

#Create the final Body
[string]$body = ConvertTo-HTML -Head $header -Body $html -PostContent "<h6>Created $(Get-Date)</h6>"

#Who to send the e-mail report to.
#Multiple e-mail addresses should be in this format "<email1@domain.com>, <email2@domain.com>"

$MailParams = @{
From = "Reports@domain.com"
To = "<guy1@domain.com>", "<guy2@domain.com>", "<guy3@domain.com>"
subject = "Monthly E-Mail report for Sales Team for $startDateFormatted - $endDateFormatted"
BodyAsHTML = $true
Attachments = "$outfilepath$outfilename"
smtpServer = "mail.domain.com"
Body = $Body
}

Send-MailMessage @MailParams 

#DONT FORGET TO DISCONNECT WITH..
Remove-pssession $session

