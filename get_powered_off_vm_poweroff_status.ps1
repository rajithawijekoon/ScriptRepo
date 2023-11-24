﻿$Report = @()

$VMs = Get-VM | Where {$_.PowerState -eq "PoweredOff"}

$Datastores = Get-Datastore | Select Name, Id

$PowerOffEvents = Get-VIEvent -Entity $VMs -MaxSamples ([int]::MaxValue) | where {$_ -is [VMware.Vim.VmPoweredOffEvent]} | Group-Object -Property {$_.Vm.Name}

foreach ($VM in $VMs) {

    $lastPO = ($PowerOffEvents | Where { $_.Group[0].Vm.Vm -eq $VM.Id }).Group | Sort-Object -Property CreatedTime -Descending | Select -First 1

    $row = "" | select VMName,Powerstate,OS,Host,Cluster,Datastore,NumCPU,MemMb,DiskGb,PoweredOffTime,PoweredOffBy

    $row.VMName = $vm.Name

    $row.Powerstate = $vm.Powerstate

    $row.OS = $vm.Guest.OSFullName

    $row.Host = $vm.VMHost.name

    $row.Cluster = $vm.VMHost.Parent.Name

    $row.Datastore = $Datastores | Where{$_.Id -eq ($vm.DatastoreIdList | select -First 1)} | Select -ExpandProperty Name

    $row.NumCPU = $vm.NumCPU

    $row.MemMb = $vm.MemoryMB

    $row.DiskGb = Get-HardDisk -VM $vm | Measure-Object -Property CapacityGB -Sum | select -ExpandProperty Sum

    $row.PoweredOffTime = $lastPO.CreatedTime

    $row.PoweredOffBy   = $lastPO.UserName

    $report += $row

}

# Output to screen

$report | Sort Cluster, Host, VMName | Select VMName, Cluster, Host, NumCPU, MemMb, @{N='DiskGb';E={[math]::Round($_.DiskGb,2)}}, PoweredOffTime, PoweredOffBy | ft -a

# Output to CSV - change path/filename as appropriate

$report | Sort Cluster, Host, VMName | Export-Csv -Path "Powered_Off_VMs.csv" -NoTypeInformation -UseCulture