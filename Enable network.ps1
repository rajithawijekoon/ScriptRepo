Connect-VIServer icdwpcorevcs41.dcsprod.dcsroot.local -User administrator@vsphere.local -Password M@nDr4k3!#



Get-VM -name "icdwpcorefil16" | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$true -StartConnected:$true -Confirm:$false