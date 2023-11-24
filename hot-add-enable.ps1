#Define Parameter
param($vmname)

#Shutdown virtual machine from Guest OS. If vmware tools is not installed this will begin to fail
shutdown-vmguest $vmname -confirm:$false

#Keep 60 seconds to change config
start-sleep -Seconds 60

#Enable CPU & Memory Hotplug Feature
$VM = Get-VM $vmname
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.memoryHotAddEnabled = $true
$spec.cpuHotAddEnabled = $true
$spec.CpuHotRemoveEnabled = $true
$VM.ExtensionData.ReconfigVM_Task($spec)

#Power On VM after the configuration changes
start-vm $vmname -confirm:$false

