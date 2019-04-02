# Working with the repository
# - Use Invoke-PowerSponse or New-CleanupPackage commands
# - Within PowerShell use e.g. (Get-PowerSponseRepository)['ProcessItem'] 
#   to get  configuration for specific repository items

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
		DefaultMethod = "WinRM"
		Actions = @("Stop", "Get")
		ActionStop = "Stop-Process"
		# Get-Process uses param "SearchString"
		ActionGet = "Get-Process"
		Methods = @("WMI", "External","WinRM")
		Parameter = @{
			Name = "-Name"
		}
		ParameterOpt = @{
			StopAll = "-StopAll"
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

	DirectoryItem  = @{
		DefaultAction = "Remove"
		DefaultMethod = "WinRM"
		Actions = @("Find", "Remove")
		ActionFind = "Find-Directory"
		ActionRemove = "Remove-Directory"
		Methods = @("WinRM")
		Parameter = @{
			Path = "-Path"
        }
        ParameterOpt = @{
			Regex = "-Regex"
			Recurse = "-Recurse"
        }
	}

	FileItem  = @{
		DefaultAction = "Remove"
		DefaultMethod = "WinRM"
		Actions = @("Find", "Remove")
		ActionFind = "Find-File"
		ActionRemove = "Remove-File"
		Methods = @("WinRM")
		Parameter = @{
			Path = "-Path"
        }
		ParameterOpt = @{
			Regex = "-Regex"
			Recurse = "-Recurse"
        }
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
