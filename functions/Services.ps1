Function Get-Service()
{
	
}

Function Edit-Service()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI", "External")]
		[string] $Method = "WMI",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[string] $Name,

		[ValidateSet("start", "stop")]
		[string] $ServiceState
	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "Name: $Name, ServiceState $ServiceState"
	Write-Verbose $Arguments

	if (!$Name)
	{
 		$Reason = 'You have to provide a service name'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	elseif (!$ServiceState)
	{
 		$Reason = 'You have to provide an ServiceState'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."

			if ($pscmdlet.ShouldProcess($target, "$ServiceState service $($Name)"))
			{

				if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
				{
					Write-Verbose "$target is offline"
					$Status = "fail"
					$Reason = "offline"
				}
				else
				{
					if ($Method -match "wmi")
					{
						if (($target -eq "localhost") -and $Credential)
						{
							$Status = "fail"
							$Reason = "localhost and WMI and credential not working"
							$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
							Continue
						}

						$res = Get-WmiObject Win32_service -Filter "name='$($Name)'" -Credential $Credential -ComputerName $target

						if (!$res)
						{
							$Status = "fail"
							$Reason = "no service (empty result)"
						}
						else
						{
							$State = $res.State
							write-verbose $State
							if (($ServiceState -match "stop") -and ($State -match "stopped"))
							{
								$Status = "pass"
								$Reason = "service already stopped"
							}
							elseif (($ServiceState -match "start") -and ($State -match "running"))
							{
								$Status = "pass"
								$Reason = "service already started"
							}
							else
							{
								$rval = $res.$("$($ServiceState)Service")().returnvalue

								write-verbose "Return value: $rval"

								if ($rval -eq 0)
								{
										$Status = "pass"
										$Reason = "service set to $ServiceState"
								}
								elseif ($rval -eq 2)
								{
									$Status = "fail"
									$Reason = "access denied"
								}
								else
								{
									$Status = "fail"
									$Reason = "Returnvalue is $rval"
								}
							}
						}
					}
					elseif ($Method -match "winrm")
					{
					}
					elseif ($Method -match "external")
					{
						Write-Verbose "Using external tools"
						Write-Verbose "BinPath: $BinPath"

						if (!(Test-Path -Path "$BinPath\psservice.exe"))
						{
							$Status = "fail"
							$Reason = "Binary $BinPath\psservice.exe not found."
						}
						else
						{
							$proc = Start-Process psservice.exe -commandline "\\$target -accepteula -nobanner $ServiceState $Name"

							if ($proc.stderr -match "verweigert" -or $proc.stderr -match "denied")
							{
								$Reason = "Access denied while set service to $ServiceState"
								$Status = "fail"
							}
							elseif ($proc.stderr -match "bereits" -or $proc.stderr -match "already")
							{
								$Reason = "Service already set to $ServiceState."
								$Status = "pass"
							}
							elseif ($proc.stdout -match "Error")
							{
									$Reason = "Error while using psservice. Use -Verbose when running the command for more information. Is service already activated? If not, use Enable-Service or Enable-RemoteRegistry."
									$Status = "fail"
									Write-Verbose $proc.stdout
									Write-Verbose $proc.stderr
							}
							elseif ($proc.stdout -match "unable to access")
							{
								$Reason = "Unable to access SCM"
								$Status = "fail"
							}
							elseif (!$proc.stderr -and !($proc.stdout -match "error"))
							{
								$Reason = "Service set to $ServiceState."
								$Status = "pass"
							}
							else
							{
								$Status = "fail"
								$Reason = "Tell the developer to better code. Something went wrong..."
								Write-Verbose $proc.stdout
								Write-Verbose $proc.stderr
							}

							if ($proc.ExitCode -eq 0)
							{
								Write-Verbose "Successfully executed psservice on $target"
							}
							else
							{
								Write-Verbose "Error while running psservice on $target"
							}

						} #binaries found

					} #External

				} #online

				$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

			} #whatif

		} #each target

	} # parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"

} # Edit-Service

Function Start-Service()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='ExternComputerName')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI", "WinRM", "External")]
		[string] $Method = "WMI",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[string] $Name
	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "Name: $Name"
	Write-Verbose "Arguments: $Arguments"

	if (!$Name)
	{
 		$Reason = 'You have to provide a service name'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."
			if ($pscmdlet.ShouldProcess($target, "start $($Name)"))
			{
				if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
				{
					$Status = "fail"
					$Reason = "offline"
					$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
				}
				else
				{
					if ($Method -match "wmi")
					{
						$ret = Edit-Service -Method wmi -ComputerName $target -Credential $Credential -Name $Name -servicestate "start" -OnlineCheck:$false
					}
					elseif ($Method -match "winrm")
					{
							$ret = Edit-Service -Method winrm -ComputerName $target -Name $Name -servicestate "start" -OnlineCheck:$false
					}
					elseif ($Method -match "external")
					{
							$ret = Edit-Service -Method external -ComputerName $target -Name $Name -servicestate "start" -OnlineCheck:$false
					}

					$ret | ? { $_.Function -match "Edit-Service" } | % { $_.Function = $Function }
					$ret | ? { $_.Arguments -match "Edit-Service" } | % { $_.Arguments = $Arguments }
					$returnobject += $ret
				} #online

			} #whatif

		} #each target

	} #parameters ok

	$returnobject
	Write-Verbose "Leaving $Function"

} #Start-Service

Function Stop-Service()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI", "WinRM", "External")]
		[string] $Method = "WMI",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[string] $Name
	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "Name: $Name, OnlineCheck: $OnlineCheck"
	Write-Verbose "Arguments: $Arguments"

	if (!$Name)
	{
 		$Reason = 'You have to provide a service name'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		Write-Verbose $targets

		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."
			if ($pscmdlet.ShouldProcess($target, "Stop $($Name)"))
			{
				if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
				{
					$Status = "fail"
					$Reason = "offline"
					$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
				}
				else
				{
					if ($Method -match "wmi")
					{
						$ret = Edit-Service -Method wmi -ComputerName $target -Credential $Credential -Name $Name -servicestate "stop" -OnlineCheck:$false
					}
					elseif ($Method -match "winrm")
					{
							$ret = Edit-Service -Method WinRM -ComputerName $target -Name $Name -servicestate "stop" -OnlineCheck:$false
					}
					elseif ($Method -match "external")
					{
							$ret = Edit-Service -Method external -ComputerName $target -Name $Name -servicestate "stop" -OnlineCheck:$false
					}

					$ret | ? { $_.Function -match "Edit-Service" } | % { $_.Function = $Function }
					$ret | ? { $_.Arguments -match "Edit-Service" } | % { $_.Arguments = $Arguments }

					$returnobject += $ret

				} #online

			} #whatif

		} #each target

	} #parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"

} #Stop-Service

Function Enable-Service()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='ExternComputerName')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI", "External")]
		[string] $Method = "WMI",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[string] $Name,

		[ValidateSet("Manual", "Automatic")]
		[string] $StartupType
	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "Name: $Name, StartupType: $StartupType, Method: $Method"
	Write-Verbose "Arguments: $Arguments"

	if ($Method -match "external")
	{
		if ($StartupType -eq "Manual")
		{
			$StartupTypeService = "demand"
		}
		else
		{
			$StartupTypeService = "auto"
		}
	}
	else
	{
		$StartupTypeService = $StartupType
	}

	if (!$Name)
	{
 		$Reason = 'You have to provide a service name'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	elseif (!$StartupType)
	{
 		$Reason = 'You have to specifiy the startuptype. Manual or Automatic.'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."
			if ($pscmdlet.ShouldProcess($target, "Enable $($Name) with StartupType $($StartupTypeService)"))
			{
				if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
				{
					Write-Verbose "$target is offline"
					$Status = "fail"
					$Reason = "offline"
				}
				else
				{
					if ($Method -match "wmi")
					{
						if (($target -eq "localhost") -and $Credential)
						{
							$Status = "fail"
							$Reason = "localhost and WMI and credential not working"
							$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
							Continue
						}

						$res = Get-WmiObject Win32_service -Filter "name='$($Name)'" -Credential $Credential -ComputerName $target

						if (!$res)
						{
							$Status = "fail"
							$Reason = "no service"
						}
						else
						{
							$rval = $res.ChangeStartMode($StartupTypeService).returnvalue
							write-verbose "Return value: $rval"

							if ($rval -eq 0)
							{
								$Status = "pass"
								$Reason = "service enabled"
							}
							elseif ($rval -eq 2)
							{
								$Status = "fail"
								$Reason = "access denied"
							}
							else
							{
								$Status = "fail"
								$Reason = "Returnvalue is $rval"
							}
						}
					}
					elseif ($Method -match "winrm")
					{
					}
					elseif ($Method -match "external")
					{
						Write-Verbose "Using external tools"
						Write-Verbose "BinPath: $BinPath"

						if (!(Test-Path -Path "$BinPath\psservice.exe"))
						{
							$Status = "fail"
							$Reason = "Binary $BinPath\psservice.exe not found."
						}
						else
						{

							$proc = Start-Process psservice.exe -commandline "\\$target -accepteula -nobanner setconfig $($Name) $($StartupTypeService)"

							if ($proc.stderr -match "verweigert" -or $proc.stderr -match "denied")
							{
								$Reason = "Access denied while enabling $Name"
								$Status = "fail"
							}
							elseif ($proc.stderr -match "kein installierter" -or $proc.stderr -match "no installed")
							{
								$Reason = "service not found"
								$Status = "fail"
							}
							elseif ($proc.stderr -match "deaktiviert" -or $proc.stderr -match "deactivated")
							{
								$Reason = "service is deactivated"
								$Status = "fail"
							}
							elseif ($proc.stdout -match "error" -or $proc.stdout -match "usage:")
							{
								$Reason = "Error while using psservice"
								$Status = "fail"
								Write-Verbose $proc.stdout
								Write-Verbose $proc.stderr
							}
							elseif ($proc.stdout -match "unable to access")
							{
								$Reason = "Unable to access service control manager"
								$Status = "fail"
							}
							elseif ($proc.stdout -and !($proc.stdout -match "error"))
							{
								$Reason = "$($Name) enabled."
								$Status = "pass"
							}
							else
							{
								$Reason = "Unspecified error"
								$Status = "fail"
								Write-Verbose $proc.stdout
								Write-Verbose $proc.stderr
							}

							if ($proc.ExitCode -eq 0)
							{
								Write-Verbose "Successfully executed psservice on $target"
							}
							else
							{
								Write-Verbose "Error while running psservice on $target"
							}

						} #Binary found

					} #External

				} #online

				$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
			} #whatif

		} #each target

	} #parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} #Enable-Service

Function Disable-Service()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI", "External")]
		[string] $Method = "WMI",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[switch] $NoRemoteRegistry,

		[string] $Name
	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "Method: $Method, Name: $Name, Onlinecheck: $OnlineCheck"
	Write-Verbose "Arguments: $Arguments"

	if (!$Name)
	{
 		$Reason = 'You have to provide a service name'
		$Status = "fail"
		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."
			if ($pscmdlet.ShouldProcess($target, "Disable Service $($Name)"))
			{
				if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 2))
				{
					Write-Verbose "$target is offline"
					$Status = "fail"
					$Reason = "offline"
				}
				else
				{

					if ($Method -match "wmi")
					{

						if (($target -eq "localhost") -and $Credential)
						{
							$Status = "fail"
							$Reason = "localhost and WMI and credential not working"
							$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
							Continue
						}

						if ($Credential)
						{
							Write-Verbose "Using wmi with credentials"
							# todo fixme add regex capability with wmi filter or with list all and -match with PS
							$res = Get-WmiObject Win32_service -Filter "name='$($Name)'" -Credential $Credential -ComputerName $target
						}
						else
						{
							# todo fixme add regex capability with wmi filter or with list all and -match with PS
							Write-Verbose "Using wmi without credentials"
							$res = Get-WmiObject Win32_service -Filter "name='$($Name)'" -ComputerName $target
						}

						if (!$res)
						{
							$Status = "fail"
							$Reason = "no service"
						}
						else
						{
							$rval = $res.ChangeStartMode('disabled').returnvalue
							write-verbose "Return value: $rval"

							if ($rval -eq 0)
							{
								$Status = "pass"
								$Reason = "service disabled"
							}
							elseif ($rval -eq 2)
							{
								$Status = "fail"
								$Reason = "Access denied to disable service"
							}
							else
							{
								$Status = "fail"
								$Reason = "Returnvalue is $rval"
							}
						}
					}
					elseif ($Method -match "winrm")
					{
						# noooot
					}
					elseif ($Method -match "external")
					{

						Write-Verbose "Using external tools"
						Write-Verbose "BinPath: $BinPath"

						if (!(Test-Path -Path "$BinPath\psservice.exe"))
						{
							$Status = "fail"
							$Reason = "Binary $BinPath\psservice.exe not found."
						}
						else
						{
							$proc = Start-Process psservice.exe -commandline "\\$target -accepteula -nobanner setconfig $Name disabled"

							if ($proc.stderr -match "verweigert" -or $proc.stderr -match "denied")
							{
								$Reason = "Access denied while disabling service"
								$Status = "fail"
							}
							elseif ($proc.stdout -match "Unable")
							{
								$Reason = "Error accessing remote host"
								$Status = "fail"
							}
							elseif ($proc.stdout -and !($proc.stdout -match "Error"))
							{
								$Reason = "Service disabled"
								$Status = "pass"
							}
							else
							{
								$Reason = "Tell the developer to better code. Something went wrong..."
								$Status = "fail"
								Write-verbose $proc.stdout
								Write-verbose $proc.stderr
							}

							if ($proc.ExitCode -eq 0)
							{
								Write-verbose "Successfully executed psservice on $target"
							}
							else
							{
								Write-Verbose "Error while running psservice on $target"
							}

						} # binaries found

					} # UseExternal

				} # host online

				$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

			} # whatif

		} # each target

	} # parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"

} # Disable-Service

Function Remove-Service()
{
	
}

