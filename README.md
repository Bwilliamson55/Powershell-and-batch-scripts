# Powershell and Batch Scripts
Some scripts I've accumulated and Made. 

Use at your own risk. \
I will try to keep them notated properly, and create an index here to give a tldr of
what each one does.

# BackupFiles
This is a very reliable, simple backup script you can schedule with task scheduler. \
I use this to incrimentally copy a spiceworks installation offsite for DR and BI \
Spiceworks and it's sqlite DB do not like multiple connections, so it's best to copy the DB file and then mess with it.

# DateTime Picker
Example of how to create a gui date time picker 

# Disable AD Computers older than a year
Useful for large environments with dead computers. Scans AD with a date cutoff and disables computer objects not touched for x time. 

# do-speak-bw
This is a fun little script to demonstrate how to use built in TTS \
Bonus points for pushing this to a victim, er I mean, volunteer's PC. 

# Dynamic Menu to pick from
Example of how to make a dynamic menu, using AD objects (Mainly OUs) 

# Exchange Daily stats report
This is a partially working script to produce HTML and text reports on daily sent/received email statistics. \
This depends on the exchange message tracking logs, so be sure to push out their retention length. \
I say this is partially working because it only pulls 'deliver' events, which is not enough to get accurate stats. 

# Export message tracking log yesterday 2020
This is a script I created recently to dump the tracking logs from Exchange 2013 \
The logs can be adjusted on the exchange server to retain more than the default 30days \
This is part of an ETL flow I built to push email stats into a database for reporting \
This can be adjusted to dump a whole year of data if the logs are that long, but it will take some time 

# Find .NET version on all AD windows computers
This was more useful 'back in the day' but it's still a good example of how to pull this information in a domain

# Find freespace on active connected AD comps
Kind of self explanitory

# Find programs with filtered AD client list
Good example of how to use interactive input to filter a resultant set. \
Specifically with AD modules

# Fix windows update error 80244022
This is most likely not my work, but when I came across this I figured it would be a good addition to the repo. \
This is a good reminder of how far we've come with patching issues in windows land.

# Flip through webpages
Part of a failed powershell based web-scraper side project. \
This was a little tool to just flip through an array of urls via IE

# Force chosen clients to gpupdate
Using invoke-command and properly elevated domain credentials, we can make sure everyone get's that new GPO you made

# Force clients to talk to wsus
Who doesn't love wsus issues? \
This is basically the same as the gpupdate push, but with wuauclt /resetauthorization /detectnow

# get hdd space
Not my work - great example on how to pull detailed information on hardware using PSobjects though.

# Get-bash quote
A fun function I generally include with all my PS profiles for some relief during the day. \
This also pairs well with 'get-goat' (Another public PS function that pulls quotes).

# get-monitors
Sometimes you really don't want to walk over to the PC and look behind the monitor.

# Hardware inventory by computer active on AD
This is a smattering of previous examples- scan AD for active PC objects given a date cutoff, \
Then scan them all for hardware information and produce a report

# QR code grabber for csv file
This helped me create QR codes quickly, for free, based on asset tags in a CSV \
I'm pretty sure I built this. 

# Scrape for Links
Failed web-scraper idea using powershell. Fun rabbit hole though

# Send custom command to filtered clients
Another frankenscript where we scan for clients, allow interactive input to filter the list, \
Then send a command we input at runtime to all clients selected \
Generally things like w32tm commands that just really need to be pushed right now are what I use this for

# Send-NetMessage
Do you like annoying your co-workers? This is a fun way to do that. \
This will push text to a popup on the target machine, assuming you have proper elevation in the domain. \
Warning- your hostname/username is generally shown in the popup. \
This is a great tool in your PSprofile.

# StartEXElIfProgramNotRunning bat
Simple batch file to check for a running process, before starting a seperate process. \
I work with some pretty antiquated systems that depend on macros- \
those macros will eat themselves like a poorly loaded dot-matrix printer sheet if they run over each other. \
Here was my solution. 

# Whos logged onto what
Scans the network for active PCs, and then tests them to see who is logged on

# YesNoMenu
This is a good example of how to do a simple yes/no menu in powershell

# WindowsPowerShell
This is my powershell profiles folder. You can copy this to C:\Users\YOU\Documents if you do not already have a profile. \
These profile files are a good example of how you can make your powershell life at work more enjoyable. \
Encorporating a good mix of fun and useful scripts as well as often used modules. \
There is a little how-to ps1 I made in here as well to help you create/find your profiles.