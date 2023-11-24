

$DestvDSObject= "VMware HCIA Distributed Switch BO3_VXR_Core_NonProd 87258a"
$DestClusterObject="BO3_VXR_Core_NonProd"
$DestDSObject="VxRail-Virtual-SAN-Datastore-87258a67-4110-4f07-b668-ea9df7a7eb48"
$vms= Get-Content "vms4.txt"


function Wait-mTaskvMotions {

    [CmdletBinding()]

    Param(

      [int] $vMotionLimit=1,

      [int] $DelayMinutes=4

    )

    $NumvMotionTasks = (Get-Task | ? { ($_.PercentComplete -ne 100) -and ($_.Description -match 'Apply Storage DRS recommendations|Relocate virtual machine')} | Measure-Object).Count

    While ( $NumvMotionTasks -ge $vMotionLimit ) {

        Write-Verbose "$(Get-Date)- Waiting $($DelayMinutes) minute(s) before checking again."

        Start-Sleep ($DelayMinutes * 60)

        $NumvMotionTasks = (Get-Task | ? { ($_.PercentComplete -ne 100) -and ($_.Description -match 'Apply Storage DRS recommendations|Relocate virtual machine')} | Measure-Object).Count

    }

   

    Write-Verbose "$(Get-Date)- Proceeding."

} # end function

function disconnect (){	
	#Disconnect all the connections
	Write-Host "Clear vCenter connections.........."  -foregroundcolor Magenta
	Disconnect-VIServer "*" -force -Confirm:$false > $null 2>&1
}# end function


foreach($vm in $vms){


$netadpt = Get-VM $vm | Get-NetworkAdapter

if($netadpt.count -ne 1 ){

Write-host "two or more network adaptors in: $vm Please migrate VM manually.Skipping:$vm" -ForegroundColor Yellow

$vm | Out-File "SkippedVMs.txt" -Force

Continue

}


$sorcvlan = Get-VM $vm | Get-NetworkAdapter | select name,@{N="vlanid" ; E={(Get-VDPortgroup $_.NetworkName).Extensiondata.Config.DefaultPortCOnfig.Vlan.VlanId} }

$destnetwork = foreach ($sorcvlan1 in $sorcvlan.vlanid){ Get-VDPortgroup -VDSwitch $DestvDSObject | where {($_.Extensiondata.Config.DefaultPortCOnfig.Vlan.VlanId) -eq "$sorcvlan1"}}

if (($destnetwork).count -ne ($netadpt).count){
   Write-host "Multiple Portgroups found for one of vLAN ID from the destination. Skipping migtration $vm " -ForegroundColor Yellow
    $vm | Out-File "SkippedVMs.txt" -Force
   Continue
   }

Move-VM $vm -Destination $DestClusterObject -Datastore $DestDSObject -NetworkAdapter $netadpt[0] -PortGroup $destnetwork[0] -Confirm:$false -RunAsync


Wait-mTaskvMotions -vMotionLimit 5


}


#Move-VM $vm -Destination (Get-VMHost -Location $DestClusterObject | Get-Random) -Datastore $DestDSObject -NetworkAdapter $netadpt[0] -PortGroup $destnetwork[0] -Confirm:$false -RunAsync 


