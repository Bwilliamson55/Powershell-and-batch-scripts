Function Get-Bash {
    $URI = "http://www.bash.org/?random"
    $HTML = Invoke-WebRequest -Uri $URI
    write-host "Here's a Bash quote: "
    ($html.ParsedHtml.getElementsByTagName("p") | ? {$_.classname -eq "qt"}).innertext | get-random
    } 