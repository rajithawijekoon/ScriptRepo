$vms = Get-Content "vms.txt"
foreach($vm in $vms){

Get-VM -Name $vm | Set-VM -Name "$vm-decom_CTASK0170402" -Confirm:$false

}