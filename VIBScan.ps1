Write-Host "`nSuccessfully Connected to vCenter Server $vcenter"

# List ESXiHosts in Cluster with Connected Status
#$ESXiHosts = Get-VMHost -State Connected
$ESXiHosts = Get-VMHost

Write-Host "`nTotal Number of ESXi hosts to scan - $($ESXiHosts.Count)`n"

#Main loop to verify each ESXi host
foreach ($ESXiHost in $ESXiHosts)
    {
        #Variable to store the untrusted VIB status
        $FoundUntrustedvibs = $False
        
        Write-Host "Checking Host - $($ESXiHost.Name)"
        if ( ($ESXiHost.ConnectionState -eq "Connected") -or ($ESXiHost.ConnectionState -eq "Maintenance") )
        {        
            $UnTrustedVIBs = @()

            try
            {
                #Execute esxcli software vib signature verify status on each ESXi host
                $esxcli = Get-EsxCli -VMHost $ESXiHost -V2
                $vibverifystatus = $esxcli.software.vib.signature.verify.Invoke()
            }
            catch
            {
                #catch the failure reason if execution of esxcli software vib signature verify fails on the ESXi host
                $VIBTrustedStatus = new-object PSObject
                $VIBTrustedStatus | add-member -type NoteProperty -Name HostName -Value $ESXiHost.Name
                $VIBTrustedStatus | add-member -type NoteProperty -Name OverallStatus -Value "Skipped"
                $VIBTrustedStatus | add-member -type NoteProperty -Name Found_Unsigned_VIBs -Value "Skipped"
                $VIBTrustedStatus | add-member -type NoteProperty -Name HostConnectionState -Value $ESXiHost.ConnectionState
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_ID -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_AcceptanceLevel -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_SignatureVerification -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name ERRORs -Value $_.Exception.Message
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Name -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Vendor -Value "NA"
                $VIBVerificationStatus+=$VIBTrustedStatus
                continue
            }

            #Identitify the Unsigned VIBs
            foreach ($vibstatus in $vibverifystatus)
            {
                if ( ($vibstatus.SignatureVerification -ne "Succeeded") -or ($vibstatus.AcceptanceLevel -eq "CommunitySupported") )
                {
                    if ( $vibstatus.SignatureVerification -ne "Not Applicable (Locker VIB)" )
                    {
                        $FoundUntrustedvibs = $True
                        $UnTrustedVIBs+=$vibstatus
                    }
                
                }
            }


            if ($FoundUntrustedvibs)
            {
                #prepre the result if there are Unsigned or Community Supported VIBs
                foreach ($UnTrustedVIB in $UnTrustedVIBs)
                {
                    $VIBTrustedStatus = new-object PSObject
                    $VIBTrustedStatus | add-member -type NoteProperty -Name HostName -Value $ESXiHost.Name
                    $VIBTrustedStatus | add-member -type NoteProperty -Name OverallStatus -Value "Not Good"

                    $ValueforUntrustedVIBs = "Found " + $UnTrustedVIBs.Count + " Unsigned/CommunitySupport VIBs"
                    $VIBTrustedStatus | add-member -type NoteProperty -Name Found_Unsigned_VIBs -Value $ValueforUntrustedVIBs
                    
                    $VIBTrustedStatus | add-member -type NoteProperty -Name HostConnectionState -Value $ESXiHost.ConnectionState
                    $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_ID -Value $UnTrustedVIB.ID
                    $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_AcceptanceLevel -Value $UnTrustedVIB.AcceptanceLevel
                    
                    if ($UnTrustedVIB.AcceptanceLevel -eq "CommunitySupported")
                    {
                        $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_SignatureVerification -Value "Community Unsigned"
                    }
                    else
                    {
                        $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_SignatureVerification -Value $UnTrustedVIB.SignatureVerification
                    }
                    
                    $VIBTrustedStatus | add-member -type NoteProperty -Name ERRORs -Value "None"
                    $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Name -Value $UnTrustedVIB.Name
                    $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Vendor -Value $UnTrustedVIB.Vendor
                    $VIBVerificationStatus+=$VIBTrustedStatus
                }
            }
            else
            {
                #prepre the result if there are NO Unsigned/CommunitySupport VIBs on ESXi host
                $VIBTrustedStatus = new-object PSObject
                $VIBTrustedStatus | add-member -type NoteProperty -Name HostName -Value $ESXiHost.Name
                $VIBTrustedStatus | add-member -type NoteProperty -Name OverallStatus -Value "Good"
                $VIBTrustedStatus | add-member -type NoteProperty -Name Found_Unsigned_VIBs -Value "Zero Unsigned VIBs found"
                $VIBTrustedStatus | add-member -type NoteProperty -Name HostConnectionState -Value $ESXiHost.ConnectionState
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_ID -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_AcceptanceLevel -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_SignatureVerification -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name ERRORs -Value "None"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Name -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Vendor -Value "NA"
                $VIBVerificationStatus+=$VIBTrustedStatus
            }

        }
        
        else
        
        {
                #prepare the result for disconnected or NotResponding Hosts in the inventory 
                $VIBTrustedStatus = new-object PSObject
                $VIBTrustedStatus | add-member -type NoteProperty -Name HostName -Value $ESXiHost.Name
                $VIBTrustedStatus | add-member -type NoteProperty -Name OverallStatus -Value "Skipped"
                $VIBTrustedStatus | add-member -type NoteProperty -Name Found_Unsigned_VIBs -Value "Skipped"
                $VIBTrustedStatus | add-member -type NoteProperty -Name HostConnectionState -Value $ESXiHost.ConnectionState
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_ID -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_AcceptanceLevel -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_SignatureVerification -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name ERRORs -Value "None"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Name -Value "NA"
                $VIBTrustedStatus | add-member -type NoteProperty -Name VIB_Vendor -Value "NA"
                $VIBVerificationStatus+=$VIBTrustedStatus
        }
       
    }


#Initialize Export Result File Name
$ResultFilename = "C:\Temp\KB89619_Verify_UnSigned_VIBs_on_Hosts_" + $vcenter + "_" + (Get-Date).tostring("dd-MM-yy-hh-mm") + ".csv"

try
{
    #Export the overall result to CSV file
    $VIBVerificationStatus | Sort-Object OverallStatus | export-csv $ResultFilename -notype -ErrorAction Stop
    Write-Host "`nPlease check the final result file - " $ResultFilename
}

catch
{
    #catch the failure and export the result to a different filename in current script execution path
    $ResultFilename = "KB89619_Verify_UnSigned_VIBs_on_Hosts_" + $vcenter + "_" + (Get-Date).tostring("dd-MM-yyyy-hh-mm-ss") + ".csv"
    $VIBVerificationStatus | Sort-Object OverallStatus | export-csv $ResultFilename -notype
    $result = Get-Item $ResultFilename
    Write-Host "`nPlease check the final result file saved in current directory - " $result.fullname
}

#Disconnect the vCenter Server
$VCConnection = Disconnect-VIServer -Server $vcenter -confirm:$false 

#End of Script