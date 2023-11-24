#Define Parameter
param($vmname,$cpu)
connect-viserver -server "icdwtcorevcs02.dcsprod.dcsroot.local" 
#Increase/Decrease CPU count
get-vm -Name $vmname| set-vm -numcpu $cpu -Confirm:$False

