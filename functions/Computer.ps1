Function Restart-Computer()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("external", "wmi")]
		[string] $Method = "wmi",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[switch] $NoRemoteRegistry,

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true
	)

	# when using pssexec, a cleanup is not possible after shutdown, obviously
	#
	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	# when using psexec wait until client is online again and cleanup services
	$ret = Edit-Computer -Command "reboot" -Credential $Credential -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName}) -OnlineCheck:$OnlineCheck -Method:$Method -NoRemoteRegistry:$NoRemoteRegistry -BinPath:$BinPath

	$ret | ? {$_.Function -match "Edit-Computer" } | % { $_.Function = "Restart-Computer" }

	$ret

	Write-Verbose "Leaving $Function"
}

Function Stop-Computer()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("external", "wmi")]
		[string] $Method = "wmi",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[switch] $NoRemoteRegistry,

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true
	)

	# when using pssexec, a cleanup is not possible after shutdown, obviously
	#
	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	# when using psexec wait until client is online again and cleanup services
	$ret = Edit-Computer -Command "shutdown" -Credential $Credential -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName}) -OnlineCheck:$OnlineCheck -Method:$Method -NoRemoteRegistry:$NoRemoteRegistry -BinPath:$BinPath

	$ret | ? {$_.Function -match "Edit-Computer" } | % { $_.Function = "Shutdown-Computer" }

	$ret

	Write-Verbose "Leaving $Function"
}

Function Edit-Computer()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("wmi")]
		[string] $Method = "wmi",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[switch] $NoRemoteRegistry,

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[ValidateSet("reboot", "shutdown")]
		[string] $Command

	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()

	$Arguments = "Command $Command, OnlineCheck: $OnlineCheck"
	Write-Verbose $Arguments

	if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'].ispresent)
	{
		$WhatIfPassed = $true
	}
	else
	{
		$WhatIfPassed = $false
	}
	Write-Verbose "whatif: $WhatIfPassed"

	if ($PSBoundParameters.ContainsKey('NoRemoteRegistry') -and $PSBoundParameters['NoRemoteRegistry'])
	{
		$NoRemoteRegistry = $true
	}
	else
	{
		$NoRemoteRegistry = $false
	}
	Write-Verbose "NoRemoteRegistry $NoRemoteRegistry"

	if (!$Command)
	{
 		$Reason = 'You have to provide an command, e.g. value reboot or shutdown for parameter -Command'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."
			$IsLocalhost = ($target -match "localhost")
			Write-Verbose "Localhost: $IsLocalhost"

			if (!$IsLocalhost -and $OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
			{
				Write-Verbose "$target is offline"
				$Status = "fail"
				$Reason = "offline"
			}
			else
			{
				if ($Method -match "wmi")
				{
					# https://msdn.microsoft.com/en-us/library/aa394058(v=vs.85).aspx
					# Win32Shutdown method of the Win32_OperatingSystem class
					# 2 reboot
					# 8 shutdown

					<#
					$ret = get-wmiobject win32_operatingsystem -computername $computername | invoke-wmimethod -name Win32Shutdown -argumentlist $_action

					#  The Reboot method can be used to restart a computer. Like the
					#  Win32Shutdown method, the Reboot method requires the user whose
					#  security credentials are being used by the script to possess the
					#  Shutdown privilege.

					gwmi win32_operatingsystem -ComputerName xxxxxxxxxxxx | Invoke-WmiMethod -Name shutdown
					# This method immediately shuts the computer down, if possible. The
					# system stops all running processes, flushes all file buffers to the
					# disk, and then powers down the system. The calling process must
					# have the SE_SHUTDOWN_NAME privilege, as described in the following
					# example.
					#
					# (gwmi win32_operatingsystem).psbase.Scope.Options.EnablePrivileges = $true
					#>

					# todo test what is displayed to the user after reboot or shutdown
					# todo add switch to wait until reboot is finished and host wieder online
					if ($pscmdlet.ShouldProcess($target, "$Command"))
					{
						try
						{
							$ret = gwmi win32_operatingsystem -ComputerName $target -ea stop
							$ret.psbase.Scope.Options.EnablePrivileges = $true
							$ret | Invoke-WmiMethod -Name $Command

							if ($ret.returnvalue -eq 2)
							{
								$Status = "fail"
								$Reason = "$Command not successfull: Access denied"
							}
							elseif ($ret.returnvalue -eq 0)
							{
								$Status = "pass"
								$Reason = "$Command Successfully executed"
							}
							else
							{
								$Status = "fail"
								$Reason = "$Command not successfull"
							}

						}
						catch [System.UnauthorizedAccessException]
						{
							$Status = "fail"
							$Reason = "$Command not successfull: access denied"
						}

					}
					else
					{
						$Status = "fail"
						$Reason = "Started with -WhatIf"
					}

				}
				elseif ($Method -match "winrm")
				{
					$Status = "fail"
					$Reason = "method not implemented yet"
				}
				elseif ($Method -match "external")
				{
					Write-Verbose "Using external tools"
					Write-Verbose "BinPath: $BinPath"
				
					if (!(Test-Path -Path "$BinPath\psshutdown.exe"))
					{
						$Status = "fail"
						$Reason = "Binary psshutdown not found."
					}
					else
					{
						# RemoteRegistry is needed for PsExec
						try
						{
							if (!$IsLocalhost -and !$NoRemoteRegistry -or (!$IsLocalhost -and $WhatIfPassed))
							{
								$err = Enable-RemoteRegistry -Method external -ComputerName $target -WhatIf:$WhatIfPassed -OnlineCheck:$false -Credential:$Credential
								$returnobject += $err
								$srr = Start-Service -ComputerName $target -Method external -Name "RemoteRegistry" -WhatIf:$WhatIfPassed -OnlineCheck:$false -Credential:$Credential
								$returnobject += $srr
								$RemoteRegistryStarted = ($srr.status -match "pass")
							}
							else
							{
								# assume RemoteRegistry is already started
								$RemoteRegistryStarted = $true
							}
						}
						catch
						{
							$Reason = "Error while enabling RemoteRegistry"
							$Status = "fail"
						}
						$RemoteRegistryStarted = $true

						if ($RemoteRegistryStarted -or $WhatIfPassed)
						{
							if ($pscmdlet.ShouldProcess($target, "$Command"))
							{
								$Param = ""
								if ($Command -match "reboot") { $Param = "-r" }

								if ($target -match "localhost")
								{
									$proc = Start-Process psshutdown.exe -commandline "-accepteula -nobanner -f -t 1 $Param"
								}
								else
								{
									$proc = Start-Process psshutdown.exe -commandline "-accepteula -nobanner -f -t 1 $Param \\$target"
								}

								if ($proc.ExitCode -eq 0)
								{
									Write-Verbose "Successfully executed binary on $target"
								}
								else
								{
									Write-Verbose "Error while running binary on $target"
									Write-Verbose "stdout"
									Write-Verbose $proc.stdout
									write-verbose "stderr"
									write-verbose $proc.stderr
								}

								# todo check stdout/stderr from psshutdown
								if ($proc.stdout)
								{
									if ($proc.stdout -match "erfolgreich" -or $proc.stdout -match "successfull")
									{
										$Status = "pass"
										$Reason = "Executed $Command"
									}
									else
									{
										$Status = "fail"
										$Reason = "Fail: $($proc.stdout), $($proc.stderr)"
									}
								} # stdout has result
								else
								{
									$Status = "fail"
										$Reason = "Fail: $($proc.stdout), $($proc.stderr)"
								}
							} # whatif
							else
							{
								$Status = "pass"
								$Reason = "Not executed - started with -WhatIf"
							}
						} #RemoteRegistry started
						else
						{
							$Status = "fail"
							$Reason = "Error while enabling RemoteRegistry"
						}

						try
						{
							if (!$IsLocalhost -and !$NoRemoteRegistry -and $RemoteRegistryStarted -or (!$IsLocalhost -and $WhatIfPassed))
							{
								Write-Verbose "Cleanup RemoteRegistry"

								$srr = Stop-Service -ComputerName $target -Method external -Name "RemoteRegistry" -WhatIf:$WhatIfPassed -OnlineCheck:$false
								$returnobject += $srr

								$drr = Disable-RemoteRegistry -Method external -ComputerName $target -WhatIf:$WhatIfPassed -OnlineCheck:$false
								$returnobject += $drr
							}
						} # disable RemoteRegistry
						catch
						{
							$Reason = "Error while disabling RemoteRegistry"
							$Status = "fail"
						}

					} # binary found

				} #UseExternal

			} # host online

			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

		} #foreach target

	} # parameters ok

	$returnobject
	Write-Verbose "Leaving $Function"
}
