# todo cleanup and update to current parameter list

Function Get-NetworkInterface()
{
	[CmdletBinding(SupportsShouldProcess=$True, DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI")]
		[string] $Method = "WMI",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[string] $InterfaceIndex,

		[string] $InterfaceDescription,

		[switch] $OnlyIndex

	)

	# todo add switch to show only active interfaces
	# get only active interfaces
	# $ret = Get-WmiObject win32_networkadapterconfiguration -Filter 'ipenabled = "true"' -ComputerName $ComputerName -Credential $Credential

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()

	$Arguments = "InterfaceIndex: $InterfaceIndex, InterfaceDescription: $InterfaceDescription, OnlyIndex: $OnlyIndex, OnlineCheck: $OnlineCheck"
	Write-Verbose "Arguments: $Arguments"

	Write-Progress -Activity "Running $Function" -Status "Initializing..."

	if (!$InterfaceIndex -and !$InterfaceDescription)
	{
		$Status = "fail"
		$Reason = "no search information supplied"
		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	# if all parameters are correctly supplied
	else
	{
		# build target list based on parameters
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		# process every target
		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Check connection to $target..."

			if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
			{
				Write-Verbose "$target is offline"
				$Status = "fail"
				$Reason = "offline"
			}
			else
			{
				Write-Progress -Activity "Running $Function" -Status "Readon network interface information on $target..."

				$ret = $null

				if (($target -eq "localhost") -and $Credential)
				{
					$Status = "fail"
					$Reason = "localhost and WMI and credential not working"
					$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
					Continue
				}

				if ($pscmdlet.ShouldProcess($target, "Reading network interface information"))
				{
					try
					{
						$ret = Get-WmiObject win32_networkadapterconfiguration -ComputerName $target -Credential $Credential -ea stop
					}
					catch
					{
						$Status = "fail"
						$Reason = "error while connecting to remote host through WMI"
					}

					if (!$ret)
					{
						$Status = "fail"
						$Reason = "no interface information"
					}
					else
					{
						$retval = @()
						foreach ($net in $ret)
						{
							Write-Progress -Activity "Running $Function" -Status "Reading information for interface $($net.Description) ($($net.index)) on $target..."

							if (($InterfaceIndex -and ($net.Index -eq $InterfaceIndex)) -or ($InterfaceDescription -and ($net.Description -match $InterfaceDescription)))
							{
								if ($OnlyIndex)
								{
									$retval += "$($net.Index)"
								}
								else
								{
									$filter = "index = '$($net.Index)'"
									Write-Verbose "Filter: $filter"
									$ConfigManagerErrorCode = (Get-WmiObject win32_networkadapter -Filter $filter -Credential $Credential -ComputerName $target | select -ExpandProperty ConfigManagerErrorCode)
									Write-Verbose "Interface Status: $( if($ConfigManagerErrorCode -ne $null) { $ConfigManagerErrorCode } else { "no status code" } )"
									$Disabled = ($ConfigManagerErrorCode -eq 22)

									$retval += "Index: $($net.Index), Disabled: $($Disabled), Description: $($net.Description), IPAddress: $($net.IPAddress), DHCPEnabled: $($net.DHCPEnabled), DNSDomain: $($net.DNSDomain)"
								}
							}
						}
						$Status = "pass"
						$Reason = $retval
					}
				} # whatif
			} # host online

			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
		} # each target
	} # parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} # Get-NetworkInterface

Function Edit-NetworkInterface()
{
	[CmdletBinding(SupportsShouldProcess=$True, DefaultParameterSetName='Default')]
	param(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI")]
		[string] $Method = "WMI",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $InterfaceIndex,

		[string] $InterfaceDescription,

		[ValidateSet("enable", "disable")]
		[string] $Command,

		[switch] $EditAll,

		[boolean] $OnlineCheck = $true
	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()

	$Arguments = "InterfaceIndex: $InterfaceIndex, InterfaceDescription: $InterfaceDescription, EditAll: $EditAll, Command $Command, OnlineCheck: $OnlineCheck"

	Write-Progress -Activity "Running $Function" -Status "Initializing..."


	if (!$InterfaceIndex -and !$InterfaceDescription)
	{
		$Status = "fail"
		$Reason = "no search information supplied"
		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."

			if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
			{
				Write-Verbose "$target is offline"
				$Status = "fail"
				$Reason = "offline"
			}
			else
			{
				if (($target -eq "localhost") -and $Credential)
				{
					$Status = "fail"
					$Reason = "localhost and WMI and credential not working"
					$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
					Continue
				}

				$Interfaces = (Get-NetworkInterface -InterfaceIndex $InterfaceIndex -InterfaceDescription $InterfaceDescription -OnlyIndex -Credential $Credential -ComputerName $target -OnlineCheck:$false | select -ExpandProperty reason)

				if ($pscmdlet.ShouldProcess($target, "$Command network interface $(if($InterfaceIndex) {$InterfaceIndex})"))
				{
					$count = $Interfaces.count

					if ($count -eq 0)
					{
						$Status = "fail"
						$Reason = "no interface found"
					}
					else
					{
						if (($count -gt 1) -and !$EditAll)
						{
							$Status = "fail"
							$Reason = "multiple interfaces found, use -$($Command)All"
						}
						else
						{
							foreach ($adapter in $Interfaces)
							{
								Write-Verbose "Processing $adapter"
								
								# todo fix reading the disable status two times (first Get-NetworkInterface and second here)
								$filter = "index = '$adapter'"
								$ret = Get-WmiObject win32_networkadapter -Filter $filter -Credential $Credential -ComputerName $target

								$Disabled = ($ret.ConfigManagerErrorCode -eq 22)
								Write-Verbose "Disabled: $($Disabled)"

								# 2 is connected # 0 disconnected # 7 media disconnected
								$NetConnectionStatus = $ret.NetConnectionStatus

								if ((!$Disabled -and ($Command -eq "enable")) -or ($Disabled -and ($Command -eq "disable")))
								{
									$Status = "pass"
									$Reason = "already in desired state"
								}
								else
								{
									# https://msdn.microsoft.com/en-us/library/aa394216(v=vs.85).aspx
									# todo use this behaviour also for other actions (service etc)
									$val = $ret.$Command()

									if ($val.Returnvalue -eq 0)
									{
										$Status = "pass"
										$Reason = "Interface set to $($Command): Index $adapter, Name: $($ret.Name)"
									}
									else
									{
										$Status = "fail"
										$Reason = "error - not changed - Returnvalue: $($val.returnvalue)"
									}
								} # not yet disabled

							} # foreach interface

						} #multiple Interface without EditAll

					} #Interface found

				} #whatif

			} # host online

			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
		} # foreach host

	} # parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} # Edit-NetworkInterface

Function Enable-NetworkInterface()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI")]
		[string] $Method = "WMI",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $InterfaceIndex,

		[string] $InterfaceDescription,

		[switch] $EnableAll,

		[boolean] $OnlineCheck = $true
	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$ret = Edit-NetworkInterface -Command "enable" -InterfaceIndex $InterfaceIndex -InterfaceDescription $InterfaceDescription -Credential $Credential -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName}) -EditAll:$EnableAll -OnlineCheck:$OnlineCheck -Method:$Method

	$ret | ? {$_.Function -match "Edit-NetworkInterface" } | % { $_.Function = "Enable-NetworkInterface" }

	$ret

	Write-Verbose "Leaving $Function"
}

Function Disable-NetworkInterface()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI")]
		[string] $Method = "WMI",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $InterfaceIndex,

		[string] $InterfaceDescription,

		[switch] $DisableAll,

		[switch] $OnlineCheck = $true
	)
	
	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$ret = Edit-NetworkInterface -Command "disable" -InterfaceIndex $InterfaceIndex -InterfaceDescription $InterfaceDescription -Credential $Credential -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName}) -EditAll:$DisableAll -OnlineCheck:$OnlineCheck -Method:$Method

	$ret | ? {$_.Function -match "Edit-NetworkInterface" } | % { $_.Function = "Disable-NetworkInterface" }

	$ret

	Write-Verbose "Leaving $Function"
}

Function Get-DNSSetting()
{
 # .\Invoke-LiveResponse\CollectionModules\NetworkConnections\Get-DNSCache.ps1
 # $a = Get-WmiObject win32_networkadapterconfiguration -Filter 'ipenabled = "true"'
 # ($a | Get-Member) -match "dns"
}

Function Set-DNSSetting()
{
 # https://msdn.microsoft.com/en-us/library/aa394217(v=vs.85).aspx
 <#
SetDNSDomain 	

Sets the DNS domain.
SetDNSServerSearchOrder 	

Sets the server search order as an array of elements.
SetDNSSuffixSearchOrder 	

Sets the suffix search order as an array of elements.
SetDynamicDNSRegistration 	

Indicates dynamic DNS registration of IP addresses for this IP-bound adapter.
 #>
}

