###############
#
# Exchange Export Message Tracking Log
#
# The purpose here is to export the entire log (With only useful fields) at first.
# Populate a DB table with this info, then run a daily export to update the table.
# End date should be no sooner than last night at 23:59:59, and start date should always be at 00:00:00
# This will keep the data sane. 
# We are trimming the file size and data sent to the DB by filtering:
# One source, and two events. STOREDRIVER + RECEIVE = A mail sent. STOREDRIVER + DELIVER = A mail received
# More info: https://docs.microsoft.com/en-us/powershell/module/exchange/get-messagetrackinglog?view=exchange-ps
# https://docs.microsoft.com/en-us/exchange/mail-flow/transport-logs/message-tracking?view=exchserver-2019

# Fields pulled will be only:
#Timestamp
#ClientIp
#ClientHostname
#ServerIp
#ServerHostname
#ConnectorId
#Source
#EventId
#MessageId
#Recipients
#RecipientStatus
#RecipientCount
#RelatedRecipientAddress
#MessageSubject
#Sender
#ReturnPath
#Directionality
#OriginalClientIp

#generate a secure password file, this is a one time one liner
#read-host -assecurestring | convertfrom-securestring | out-file C:\temp\mysecurestring.txt

$username = "domain\administrator"
$password = Get-Content 'C:\path\mysecurestring.txt' | ConvertTo-SecureString
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password

#Connect to the Exchange Server using the secure cred above
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://SPI-exch-01.shorepowerinc.local/PowerShell/ -Authentication Kerberos -Credential $cred

Import-PSSession $Session

#DONT FORGET TO DISCONNECT WITH..
# Remove-pssession $session

#Variables - not all are used
write-host "Assigning Variables..."
$today = (get-date -Format M-d-yy)
$timestamp = (get-date -Format HHmmtt)
$outfilepath = "C:\path\"
$outfilename = "EmailTrackingLogPastDay.csv"

$TheDate=Get-Date
#Subtract 1 day from todays date (report ending day) and 1 days from todays date (report starting day)
$startDateFormatted=$TheDate.AddDays(-2).ToShortDateString()
$endDateFormatted=$TheDate.AddDays(-1).ToShortDateString()

#keep the cmdlet readable by putting the field list into this var
$fields = "Timestamp", "ClientIp", "ClientHostname", "ServerIp", "ServerHostname", "ConnectorId", "Source", "EventId", "MessageId", "Recipients", "RecipientStatus", "RecipientCount", "RelatedRecipientAddress", "MessageSubject", "Sender", "ReturnPath", "Directionality", "OriginalClientIp"

#Get the tracking log and export to a CSV.
#To trim the file- we are using one source, and two events. STOREDRIVER + RECEIVE = A mail sent. STOREDRIVER + DELIVER = A mail received
write-host "Reading Logs"
Get-MessageTrackingLog -Start "$startDateFormatted 00:00:00" -End "$endDateFormatted 23:59:59" -ResultSize Unlimited | Select $fields | ? {($_.Source -eq "STOREDRIVER") -and ($_.EventId -eq "RECEIVE" -or $_.EventId -eq "DELIVER")} | Export-CSV "$outfilepath$outfilename" -NoType 

#DONT FORGET TO DISCONNECT WITH..
Remove-pssession $session

