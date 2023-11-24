connect-viserver 

$hosts = Get-VMHost
$User = Read-Host -Prompt 'Input the esx host user (EX root or your DCSutil Account)'
$Pass = Read-Host -Prompt 'Input Password'

$cmdsub = @'

/etc/init.d/slpd stop;

/etc/init.d/slpd status;

esxcli network firewall ruleset set -r CIMSLP -e 0;

chkconfig slpd off;

chkconfig --list | grep slpd;

'@

$secPswd = ConvertTo-SecureString $Pass -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential ($User, $secPswd)

:outer foreach($esx in $hosts){


    write-host "Starting SSH service on $esx.name" -ForegroundColor DarkBlue

    try
    {
        Get-VMHostService -VMHost $esx | where{$_.Key -eq 'TSM-SSH'} | Start-VMHostService -Confirm:$false | Out-Null
        $ErrorActionPreference = 'Stop'
        $session = New-SSHSession -ComputerName $esx.Name -Credential $cred –AcceptKey

    }
    catch
    {
        $User2 = "root"
        $Pass2 = "PTS05icd"

        $secPswd2 = ConvertTo-SecureString $Pass2 -AsPlainText -Force
        $cred2 = New-Object System.Management.Automation.PSCredential ($User2, $secPswd2)

        try
        {
            Write-Host "Using default root passwords"
            $session2 = New-SSHSession -ComputerName $esx.Name -Credential $cred2 –AcceptKey

        }
        catch
        {

            do
            { 
                $success = $false
                write-host "Starting SSH service on $esx.name failed with error. Usually this means the authentication failed. Please enter another username" -ForegroundColor Red
                $User3 = Read-Host -Prompt 'Input the esx host user (EX root or your DCSutil Account) or if need to skip $($esx.name) host Please press 1 :' 
                    if($User3 -eq 1)
                    {

                        continue outer

                    }
                $Pass3 = Read-Host -Prompt 'Input Password :'


                $secPswd3 = ConvertTo-SecureString $Pass3 -AsPlainText -Force

                $cred3 = New-Object System.Management.Automation.PSCredential ($User3, $secPswd3)

                    try
                    {
                        $session3 = New-SSHSession -ComputerName $esx.Name -Credential $cred3 –AcceptKey
                    }
                    catch
                    {
                        continue                   
                    }

                $success = $true


            }       
            until($success -eq $true)
         }
    }
    Finally
    {
        # Set value back to default value
        $ErrorActionPreference = 'Continue'
    }

    if($session.connected -eq $True)
    {
        Invoke-SSHCommand -SSHSession $session -Command $cmdSub | Select -ExpandProperty Output
        write-host "Stoping SSH service on $esx.name" -ForegroundColor DarkBlue

        Remove-SSHSession -SSHSession $session | Out-Null
    }

    if($session2.connected -eq $True)
    {
        Invoke-SSHCommand -SSHSession $session2 -Command $cmdSub | Select -ExpandProperty Output
        write-host "Stoping SSH service on $esx.name" -ForegroundColor DarkBlue

        Remove-SSHSession -SSHSession $session2 | Out-Null
    }

    if($session3.connected -eq $True)
    {
        Invoke-SSHCommand -SSHSession $session3 -Command $cmdSub | Select -ExpandProperty Output
        write-host "Stoping SSH service on $esx.name" -ForegroundColor DarkBlue

        Remove-SSHSession -SSHSession $session3 | Out-Null
    }

    

    Get-VMHostService -VMHost $esx | where{$_.Key -eq 'TSM-SSH'} | Stop-VMHostService -Confirm:$false | Out-Null

}