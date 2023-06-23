$pad = "\\fileserver\temp\Process";
Set-Location -Path $pad

if((get-childitem $path  | where {$_.Extension -match "pdf"}).count -gt 0)
{
    Write-Host "Er staan onverwerkte PDF bestanden"

}else
{
    Write-Host "Geen onverwerkte PDF bestanden Scanshare is OK"
}