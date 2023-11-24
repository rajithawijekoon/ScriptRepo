Function Enable-MemHotAdd($vm){
    $vmview = Get-vm $vm | Get-View 
    $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

    $extra = New-Object VMware.Vim.optionvalue
    $extra.Key="mem.hotadd"
    $extra.Value="true"
    $vmConfigSpec.extraconfig += $extra
    $extra2 = New-Object VMware.Vim.optionvalue
    $extra2.Key=”vcpu.hotadd”
    $extra2.Value=”true”
    $vmConfigSpec.extraconfig += $extra2

    $vmview.ReconfigVM($vmConfigSpec)
}


$VMs = Get-Content "VMs.txt"

foreach ( $server in $VMs) {

Write-Host "------------------------------------------------- "
Write-Host "starting $server "
Write-Host " "
Write-Host " "

$VMView = Get-VM $server | Get-View 
$VMcpu  = $VMView.Config.Hardware.NumCpu
$vmem   = $VMView.Summary.Config.MemorySizeMB/1024

Write-Host "Current CPU=$VMcpu & Memory=$vmem GB"

if(    ($VMcpu -le 2) -and ($vmem -le 4 )   )     

{

Write-Host "setting $server CPU and memory to 2 and 4"
Get-VM -Name $server | Set-VM -MemoryGB "4" -NumCpu "2" -Confirm:$false  

Write-Host " "
Write-Host " "

}

else{

Write-Host 'CPU and memory more than 2 and 4'

Write-Host " "
Write-Host " "

}

Write-Host "Enabeling CPU and Memory hotplug in $server"
Enable-MemHotAdd $server

Write-Host " "
Write-Host " "


Write-Host "powering up the server $server"
Start-VM -VM $server -Confirm:$false 

Write-Host " "
Write-Host "------------------------------------------------- "
}
