$vmList = Get-Content "ICD_Console1.txt"
$secpasswd = ConvertTo-SecureString "1qaz2wsx@" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("root", $secpasswd)


#Credentials 
$user_dcsutil = "dcsutil\Athamsh"
$pwd_dcsutil = "proTools10hd"

$server = "icdwpcorevcs41.dcsprod.dcsroot.local"
$permission_user = "DCSUTIL\WW Project_Trio_Admin"
$role = "Console User"
	
Connect-VIServer $server -User $user_dcsutil -Password $pwd_dcsutil

foreach($vm in $vmList){
	write-host "adding permission to $vm"
	New-VIPermission -Role $role -Principal $permission_user -Entity $vm 

}