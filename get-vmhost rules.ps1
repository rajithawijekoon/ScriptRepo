$VMList = Get-Content ".\VMs.txt"
$report = @()
foreach ($line in $VMList) {


Try{
Stop-VM -VM $line -Confirm:$false -ErrorAction stop

}
Catch{
Write-host 'VM Not found'
}

}