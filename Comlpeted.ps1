 $vcenter="sg8wpcorevcs01.dcsprod.dcsroot.local"
 $pswd="M@nDr4k3!#"
 $user='administrator@vsphere.local'
 $esx_host="sg8upcoreesx05m.dcsutil.dcsroot.local"
 $unmap_volume="SG8_UCS-POD_STD_VNX-8000_VCHA"


Set-PowerCLIConfiguration -WebOperationTimeoutSeconds -180000 -Scope Session -Confirm:$false > $null 2>&1
Connect-VIServer $vcenter -User $user  -Password $pswd > $null 2>&1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
 
 
 $pingblock = {
     param($vcenter,$user,$pswd,$esx_host,$unmap_volume )
     $Agr = @{volumelabel = $unmap_volume}
     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12    
     try {
         Connect-VIServer $vcenter -User $user -Password $pswd > $null 2>&1 
         $esxcli = get-vmhost $esx_host | get-esxcli -V2
        }
    catch { "Error" }
       if  (!$error) {
           Write-host "Successfully connected to $vCenter" -ForegroundColor Green
            } else {
            Write-host "$Error" -ForegroundColor Red
            break
           }
     
     Write "Unmap Initiated"
      $esxcli.storage.vmfs.unmap.invoke($Agr)
     }
     
     $jobid= (Start-Job $pingblock -Arg $vcenter, $user,$pswd,$esx_host,$unmap_volume).Id

    Do{
        Sleep 5
        $status1 = (Get-job $jobid).state
        $status2 = Receive-Job $jobid
        #Write-Host $status1
        Write-Host $status2 -ForegroundColor Green
        
        } until (($status2 -eq "Unmap Initiated") -or ($status1 -ne "Running"))

$esxcli1 = get-vmhost $esx_host | get-esxcli -V2
$uuid = ($esxcli1.storage.filesystem.list.invoke() | Where-Object VolumeName -EQ $unmap_volume | Select-Object UUID).uuid
$loglineCount = (Get-Log -VMHost (Get-VMHost $esx_host) hostd ).LastLineNum

do {sleep 1
    Write-Host "#" -NoNewline
    $hostd = (Get-Log -VMHost (Get-VMHost $esx_host) hostd -StartLineNum 45000).Entries
} until ($hostd.Entries | Where ($_ -like "*Unmap*") ) #-and  ($_ -contains "*$uuid*")})

Disconnect-VIServer -Force -Confirm:$false
