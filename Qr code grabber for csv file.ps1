# QR Maker
#V1
#Using barcodes4.me I will grab qr images and save them based on a csv array of assettags

$csvpath = "C:\Users\path\to\csv\"
$csvfile = "Assettagsforqr.csv"
$outputpath = "C:\Users\USER\path\QRcodes\"

$csvcontent = gc $csvpath$csvfile

$url1 = "http://www.barcodes4.me/barcode/qr/qr.png?value="
$url2 = "&size=7&ecclevel=3"

$wc = New-Object System.Net.WebClient

Foreach ($Asset in $csvcontent) {
        write-host "Grabbing $Asset"
        $wc.DownloadFile("$url1$Asset$url2", "$outputpath$asset.png")
        }

 Write-host "Done."
 start $outputpath