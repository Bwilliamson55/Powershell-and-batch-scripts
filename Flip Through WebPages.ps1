### IE Flipbook
#
### This is going to be a function/script just to flip through an array of URL's
### Why? Well for scraping programs, I want to browse all links the scraper gathers up, to see which pages it scraped. 

$ie = new-object -com "InternetExplorer.Application"
$ie.visible = $true

$array = @()
$array = get-content C:\temp\test.txt

Write-Host "There are " $array.count " Links to flip through."
Read-Host `r "Press any key to continue"

foreach ($link in $array) {
Write-host "Navigating to $link `r" -fore yellow 
$ie.navigate($link)
Read-Host "Press Any Key to go to the Next Page"
}

write-host "You've Seen all the Pages!" `r
Read-Host "Press any Key to Exit"
$ie.quit
Exit