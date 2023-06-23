
#Ask first name, last name,
#Enter password (later generate password)

#Add user to multiple groups based on selection of department(eg sales, customerservers ...)
#Example: $GroupName = @("group1","group2")

# set default email and secondary email (proxyAddress)

#Invoke sheduled task
#Invoke-Command -ComputerName xyz -ScriptBlock {schtask /run /tn "taskname"}