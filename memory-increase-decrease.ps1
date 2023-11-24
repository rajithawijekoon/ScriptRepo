#Define Parameter
param($vmname,$memory)

#Increase/Decrease Memory
get-vm -Name $vmname| set-vm -MemoryGB $memory -Confirm:$False
