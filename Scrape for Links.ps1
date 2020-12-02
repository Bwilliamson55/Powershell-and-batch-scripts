### Scrape a URL for all links on that domain.
### Currently configured for only https
#
### Hopefully I'll get this to a point where we can read user input to dictate depth of the scan, as well as writing this scan to a log for other scripts.
#
# Update 2020 - This was a fun experiment. Web Scraping through powershell is not ideal, and I was never happy with the results here. 
# This was aimed at a warehouse/wholesaler type website with a simple sitemap. I've redacted the original URL, but git history will probably betray me.

#Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$URI = "https://www.redacted/"
    $HTML = Invoke-WebRequest -Uri $URI 
    $Skip = @()
    $Poke = @()
    $links = @()


#Top Level Scan
    $Links = $HTML.links | select href
        foreach ($link in $links){
        write-host $Link.href " is Link"
            #Is the link already on the skip list?
                if ($skip -contains $link.href) {
                     Write-Host $link.href "Link already on skip list. Skipping." -fore yellow
                } 
           else {            
                #Does it start with http, or https? If http skip it.

                    If ($link -notcontains $URI -and $link.href.StartsWith("http")) {
                        Write-Host $link.href " Link outside of chosen domain. Adding to skip list." -fore Yellow
                        $poke += $link.href
                    }
                    ElseIf ($link -match "http:" -or $link.href -eq "/") {
                         Write-Host "Link is not secure, or root. Adding " $link.href " to skip list" -fore yellow
                         $Skip += $link.href
                    }
                    elseif ($link -notcontains $URI -and !($link.href.StartsWith("http"))) {
                        Write-Host $link.href " Looks like a local link. Adding to Poke list." -fore Cyan
                        $poke += $link.href
                    }
                }
        }
                Write-host `r "Here's the root Skip list:`r" -fore yellow
                $skip
                Write-host "`r`nHere's the root poke list:`r" -fore cyan
                $poke
                Read-Host `r "To Continue Press any Key."

write-host "`r`n Poke Time`r`n" -fore yellow
$poke2 = @{}

    Foreach ($link in $poke) {
        #Is the link already on the skip list?
                if ($skip -contains $link) {
                     Write-Host "Link already on skip list. Skipping." -fore yellow
                } 
           else {
                    if ($link -match $URI -and $skip -notcontains $link){
                        write-host $link " Contains the domain"
                        if ($link -eq $URI){
                            write-host $link.href "This link is the root URL. Not adding." -fore yellow
                            $skip += $link
                            }
                        else {
                            write-host $link " Adding to Poke list." -fore Cyan
                            $Full = $link                            
                            $Fulllinks = Invoke-WebRequest -Uri $Full
                            $Poke2.$Full = @{}
                            $Poke2.$Full = $Fulllinks.links | select -ExpandProperty href | ? {$Skip -notcontains $_} | Get-Unique
                            }
                        }
                 elseif ($link -notmatch "http" -and $link -notlike "*://*") {
                        write-host $link " Must be local, appending to root and creating poke list."
                        $Full = $URI + $link
                        $Poke2.$Full = @{}
                        $Fulllinks = Invoke-WebRequest -Uri $Full
                        $Poke2.$Full = $Fulllinks.links | select -ExpandProperty href | ? {$Skip -notcontains $_ -and $Poke -notcontains $_} | Get-Unique
                        }
           }
    }

    foreach ($link in $poke2.keys) {
        write-host "Value is: $link" `r`n
        write-host "And the full hash item is: "$poke2[$link]
        }
        









<#
    write-host "Scraping Home Page Of ${URI}"

    $SpecialItems = @()

    #$SpecialItems = ($html.ParsedHtml.getElementsByTagName("div") | ? {$_.classname -eq "homespecialitem" -or $_.classname -eq "homespecialitemend" -or $_.classname -eq "homespecialitemstart"}).outertext
    $SpecialItems = ($html.allelements | ? {$_.class -eq "homespecialitem" -or $_.class -eq "homespecialitemend" -or $_.class -eq "homespecialitemstart"}).outertext

#>