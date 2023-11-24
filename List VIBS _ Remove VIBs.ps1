


$hostlist = Get-Cluster "Slough Shared DR UCS POD"  | Get-VMHost

Foreach($vmhost in $hostlist) {

$esxcli = get-vmhost $vmhost | Get-EsxCli -V2

$vibname=$esxcli.software.vib.list.Invoke() | Where { $_.Name -match "hio"}

$vmhost.Name ,$vibname

}


$esxcli.software.vib.remove.Invoke($false,$true,$false,$true,$vibname)

write($vmhost.VMSwapfileDatastore)

$esxcli.storage.core.device.setconfig.Invoke(

write-host $vibname