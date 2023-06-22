
## Prerequistit:
# Update primary dns to the network interface befor joining the machine

set-DnsClientServerAddress�-InterfaceIndex�2�-ServerAddresses�("Primary DNS IP address")
set-DnsClientServerAddress -InterfaceAlias Ethernet -AddressFamily IPv4 |Select-Object ServerAddresses�

#Once DNS IP is updated, then execute below cmd. 
Add-Computer -ComputerName $computers -Domain "YourDomainName" -Restart
