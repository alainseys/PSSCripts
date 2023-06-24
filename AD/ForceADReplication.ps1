param(
    [ValidateSet("ExtraSuper","Normal")]
    [string]$Mode = 'Normal'
)

$DomainControllers = Get-ADDomainController -Filter *
ForEach ($DC in $DomainControllers.Name) {
    Write-Host "Processing for "$DC -ForegroundColor Green
    If ($Mode -eq "ExtraSuper") {
        REPADMIN /kcc $DC
        REPADMIN /syncall /A /e /q $DC
    }
    Else {
        REPADMIN /syncall $DC "dc=domainname,dc=local" /d /e /q
    }
}