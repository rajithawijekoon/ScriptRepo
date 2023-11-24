
Connect-CIServer "ppdc.pd-cloud.com"

$vm=$civms=$null

$civms= Import-Csv "PPDC.csv"

foreach($line in $civms){

$vm=$line.name
Write-Host "`nSelected VM: $vm"

if( (Get-CIVM -ID $line.id).Name -eq $line.name){

Write-Host "VM Found $vm" -ForegroundColor Green


if( (Get-CIVM -ID $line.id).Status -eq "Poweredoff"){

Write-Host "VM power Status: Powered Off "
sleep 1
Write-Host "Deleting VM : $vm " -ForegroundColor Magenta

(Get-CIVM -ID $line.id).ExtensionData.Delete()

        }


else{ 

Write-Host "VM power Status: Powered On "
Write-Host "VM is Powered On. Can not be deleted." -ForegroundColor Yellow }

    } 

else{ Write-Host "VM not found.Please check the VM name or vm ID" -ForegroundColor Yellow 
sleep 1
    }


$vm=$null

}

Write-Host "`nBatch finished. Disconnecting from vCloud Director" -ForegroundColor Yellow

Disconnect-CIServer * -confirm:$false
2\; , /                      


Get-CIVM -Id 



Get-CIVM -Id "urn:vcloud:vm:9fd0109c-e958-4611-99d4-6814801b4614"


Get-View -Id "urn:vcloud:vm:80aa259a-d8e2-4d42-a171-a1b3696ef6a6"



nutanix/4u

(Get-CIView -Id "urn:vcloud:vm:80aa259a-d8e2-4d42-a171-a1b3696ef6a6")


Get-VM -Name "k2devsvc01"



