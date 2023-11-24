Connect-VIServer icdwpcorevcs41.dcsprod.dcsroot.local


$profile=(Get-VMHost icdupcoreesx101m.pearsontc.com | Get-VMHostProfile).Name


Get-VMHost -Name icdupcoreesx101m.pearsontc.com |
Test-VMHostProfileCompliance -UseCache -ErrorAction SilentlyContinue |

Select @{N='VMHost';E={$_.VMHost.Name}},

    @{N='VMHostProfile';E={$_.VMHostProfile.Name}},

    @{N='Compliance';E={if($_.IncomplianceElementList){'Not compliant'}else{'Compliant'}}},

    @{N='CheckDate';E={$_.VMHost.ExtensionData.ConfigIssue.CreatedTime}},

    @{N='Message';E={$_.VMHost.ExtensionData.ConfigIssue.FullFormattedMessage}}



    $profile=(Get-VMHost icdupcoreesx44m.ic.ncs.com | Get-VMHostProfile) 

    Apply-VMHostProfile -Entity icdupcoreesx44m.ic.ncs.com -Profile $profile -Confirm:$false





   $profile= Get-VMHost dn1upcoreesx32m.dcsutil.dcsroot.local | Get-VMHostProfile
    

if($profile -ne $null){

   $Compliance = Get-VMHost -Name dn1upcoreesx32m.dcsutil.dcsroot.local | Test-VMHostProfileCompliance 
   $ComplianceStatus = $Compliance.ExtensionData.ComplianceStatus
  
  if($ComplianceStatus -eq $null){

  Write-Host "Host is complaint with attached host profile"
  
  }

  else{
   
   Write-Host "Host is not complaint with attached host profile"

   }

   }

   else{
   
   Write-Host "no host profile attached"
   
   
   }

   if ($Compliance){
   $ComplianceStatus = $Compliance.ExtensionData.ComplianceStatus
   }

   elseif ($profile){
   $ComplianceStatus = "Compliant"
   }

   else

    {

    $ComplianceStatus = "No Profile Attached!"
    Write-Host $ComplianceStatus

    }

   if($ComplianceStatus -eq "Compliant"){
   
   Write-Host "Host is complaint with attached host profile"

   }


   else{
   
   Write-Host "Host is not complaint with attached host profile"

   }

   