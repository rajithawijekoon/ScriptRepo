$User= $null
$role= $null
$rolelist= $null
$error.clear()

$VMs= Get-Content "vmlist.txt"
$domain = Read-Host -Prompt 'Please enter the domain ex: WRK, Dcsutil, Athens' 
$user = Read-Host -Prompt 'Please enter the user ID or AD group'


try{

Get-VIPermission -Principal $domain\$User  > $null 2>&1

} catch{"Error"}



If(!$error)
{

 Write-Host "`n`nFound User: $User in Domain : $domain " -ForegroundColor Green

 Sleep 2
 Sleep 2
#$role = Read-Host -Prompt 'Please enter the role name'

DO{
		$x=1
		$rolelist = Get-VIRole | select name -unique | sort name
		Write-Host "`nRoles that are available in vCenter"
		$rolelist | %{Write-Host $x":" $_.name ; $x++}
		$x = Read-Host "Enter the number of the required Role"
		$role = $rolelist[$x-1].name
 } while($role -eq "")

 Sleep 2
 Write-Host "`n`nSelected Role : $role `n " -ForegroundColor Yellow




foreach($vm in $VMs) {

$error.clear()

try{

Get-VM $vm  > $null 2>&1

} catch{"Error"}


If(!$error){

Sleep 2
Get-VM -Name $vm | New-VIPermission -Role (Get-VIRole -Name $role ) -Principal $domain\$User > $null 2>&1
Write-Host " Permission provided to VM : $vm " -ForegroundColor Green

}


else{ 

Sleep 2
Write-Host "`nVM named $vm not found in vCenter. Please check VM name and try again" -ForegroundColor Red
New-Object -TypeName PSCustomObject -Property @{ VMName=$vm } | Export-Csv "not found VM list.csv" -Force -Append -NoTypeInformation
}


}
Sleep 2
Write-Host "`n`nNot Found VM list has been exported to ./not found VM list.csv" -ForegroundColor Yellow

}



else{
Sleep 2
Write-Host "`n`nCan not find user :$user.please check the username and try again" -ForegroundColor Red

Exit

}


