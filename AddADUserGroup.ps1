$hostList = Get-Content "\\ICDWPVIRTAPP03\Pubudu\PUM\Host_list.txt"
echo ""
echo ""
foreach($line in $hostList)
{ 
   echo ""
   echo  $line
   echo "============"
   echo ""
   Get-AdvancedSetting -Entity (Get-VMhost -Name $line) -Name 'Config.HostAgent.plugins.hostsvc.esxAdminsGroup' | Set-AdvancedSetting -Value 'Esx Admins' -confirm:$false
   
   
}
echo ""