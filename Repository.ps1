$Script:Repository = @{

	ServiceItem = @{
		DefaultAction = "Disable"
		DefaultMethod = "WMI"
		Actions = @("Disable", "Stop", "Start", "Enable")
		ActionStart = "Start-Service"
		ActionStop = "Stop-Service"
		ActionEnable = "Enable-Service"
		ActionDisable = "Disable-Service"
		Methods = @("WMI", "External")
		Parameter = @{
			Name = "-Name"
		}
	}

	TaskItem = @{
		DefaultAction = "Disable"
		DefaultMethod = "External"
		Actions = @("Disable", "Enable", "Get")
		ActionEnable = "Enable-ScheduledTask"
		ActionDisable = "Disable-ScheduledTask"
		ActionGet = "Get-ScheduledTask"
		Methods = @("External")
		Parameter = @{
			SearchString = "-SearchString"
		}
	}

	ProcessItem = @{
		DefaultAction = "Stop"
		DefaultMethod = "WMI"
		Actions = @("Stop", "Get")
		ActionStop = "Stop-Process"
		# Get-Process uses param "SearchString"
		ActionGet = "Get-Process"
		Methods = @("WMI", "External")
		Parameter = @{
			Name = "-Name"
		}
	}

	FileHandleItem = @{
		DefaultAction = "Get"
		DefaultMethod = "External"
		Actions = @("Get")
		ActionStop = "Get-FileHandle"
		Methods = @("External")
		Parameter = @{
			ProcessName = "-ProcessName"
			
		}
	}

	NetworkInterfaceItem = @{
		DefaultAction = "Get"
		DefaultMethod = "wmi"
		Actions = @("Get", "Disable", "Enable")
		ActionGet = "Get-NetworkInterface"
		ActionEnable = "Enable-NetworkInterface"
		ActionDisable = "Disable-NetworkInterface"
		Methods = @("wmi")
		Parameter = @{
			InterfaceDescription = "-InterfaceDescription"
		}
	}

	ComputerItem = @{
		DefaultAction = "Stop"
		DefaultMethod = "wmi"
		Actions = @("Stop", "Restart")
		ActionStop = "Stop-Computer"
		ActionRestart = "Restart-Computer"
		Methods = @("wmi")
		Parameter = @{}
	}


<# NOT IMPLEMENTED YET
	FirewallItem = @{
		DefaultAction = "Get"
		DefaultMethod = "WMI"
		Actions = @("Get", "Set")
		ActionGet = "Get-FirewallRule"
		Methods = @("WMI", "External")
		Parameter = @{
			Binary = "-Binary"
			Protocol = "-Protocol"
			Port = "-Port"
		}
	}
#>

<# NOT IMPLEMENTED YET
	FileItem  = @{
		DefaultAction = "Find"
		DefaultMethod = "WMI"
		Actions = @("Find", "Remove")
		ActionFind = "Find-File"
		Methods = @("WMI", "External")
		Parameter = @{
			Path = "-Path"
			Name = "-Name"
	}
#>

<# NOT IMPLEMENTED YET
	RegistryHiveItem = @{
		DefaultAction = "Get"
		DefaultMethod = "WMI"
		Actions = @("Get", "Set", "Remove")
		ActionGet = "Get-RegistryKey"
		Methods = @("WMI", "External")
		Parameter = @{
			Key = "-Key"
		}
	}
#>

}
