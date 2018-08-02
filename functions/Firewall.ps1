Function Get-FirewallRule()
{

}

Function Set-FirewallRule()
{
	# https://support.microsoft.com/en-us/kb/947709
	# netsh advfirewall firewall add rule ?
	# netsh advfirewall firewall add rule name="My Application" dir=in action=allow program="C:\MyApp\MyApp.exe" enable=yes remoteip=157.60.0.1,172.16.0.0/16,LocalSubnet profile=private
	# Add rule name="Block outgoing connections to 4848" dir=out remoteport=4848 action=block
	# PowerShell
	# $fw=New-object -comObject HNetCfg.FwPolicy2
	# $fw.rules | findstr /i "whaturlookingfor"
	# $fw.rules | select name | select-string "sql"
	# $fw.rules | where-object {$_.Enabled -eq $true -and $_.Direction -eq 1} Helped me arrive at this (inbound enabled)
	# further, you can select only certain properties of the rule. $fw.Rules | where-object {$_.Enabled -eq $true -and $_.Direction -eq 1} | Select-Object -property name, direction, enabled
}
