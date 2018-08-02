Function Get-ScheduledTask()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("External")]
		[string] $Method = "External",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		#todo add to Edit-ScheduledTask and to disable/enable task
		[switch] $NoRemoteRegistry,

		[switch] $OnlineCheck = $true,

		[string] $SearchString,

		[switch] $PrintXML,

		[switch] $OnlyTaskName

	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()

	$Arguments = "SearchString: $SearchString"
	Write-Verbose "Arguments: $Arguments"

	if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'])
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

	if (!$SearchString)
	{
 		$Reason = 'You have to provide a task name or a part from the binary path'
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
					$Status = "fail"
					$Reason = "method not implemented yet"
				}
				elseif ($Method -match "winrm")
				{
					$Status = "fail"
					$Reason = "method not implemented yet"
				}
				elseif ($Method -match "external")
				{
					Write-Verbose "Using method external"
					Write-Verbose "BinPath: $BinPath"
				
					if (!(Test-Path -Path "$BinPath\psexec.exe"))
					{
						$Status = "fail"
						$Reason = "Binary psexec not found."
					}
					else
					{
						# RemoteRegistry is needed for PsExec
						<# NOT USED - SCHTASKS IS USED DIRECTLY AGAINST REMOTE HOST
						try
						{
							if (!$IsLocalhost -and !$NoRemoteRegistry -or (!$IsLocalhost -and $WhatIfPassed))
							{
								$err = Enable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false -WhatIf:$WhatIfPassed

								$returnobject += $err
								$srr = Start-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false -WhatIf:$WhatIfPassed
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
							Write-Verbose "Error while enabling and starting RemoteRegistry"
							$Reason = "Error while enabling RemoteRegistry"
							$Status = "fail"
						}
						#>
						$RemoteRegistryStarted = $true

						if ($pscmdlet.ShouldProcess($target, "$Function $SearchString"))
						{
							if ($RemoteRegistryStarted -or $WhatIfPassed)
							{
								# Output of schtasks is written in OS language
								# therefore we use XML output which is not written in OS language

								if ($IsLocalhost)
								{
									$proc = Start-Process schtasks.exe -commandline "/query /xml one"
								}
								else
								{
									#$proc = Start-Process psexec.exe -commandline "\\$target -accepteula -nobanner schtasks /query /xml one"
									$proc = Start-Process schtasks.exe -commandline "/S $target /query /xml one"
								}

								if ($proc.ExitCode -eq 0)
								{
									Write-Verbose "Binary successfully executed on $target"
								}
								else
								{
									$Status = "fail"
									$Reason = "Error while running binary on $target"
									Write-Verbose "stdout"
									Write-Verbose $proc.stdout
									Write-Verbose "stderr"
									Write-Verbose $proc.stderr
								}

								if ($proc.stdout -and ($proc.ExitCode -eq 0))
								{
									# combination of comments and task xml allows OS independancy
									try
									{
										$res = [xml] $proc.stdout
										$Comments = $res.tasks."#comment"
										$Tasks = $res.tasks.Task
									}
									catch
									{
										write-error "schtasks output could not be converted to XML"
									}
									$TaskFound = $false
									$FoundTasks = ""
									for ($i=0; $i -le ($Tasks.count - 1); $i++)
									{
										Write-Verbose "Processing task $($comments[$i].Trim())"
										try
										{
											$FoundTaskName = ($Comments[$i] -match $SearchString)
											$FoundTaskContent = ($Tasks[$i].OuterXml -match ($SearchString))
										}
										catch
										{
											$FoundTaskName = ($Comments[$i].Contains($SearchString))
											$FoundTaskContent = ($Tasks[$i].OuterXml.Contains($SearchString))
										}

										if ($FoundTaskName -or $FoundTaskContent)
										{
											Write-Verbose "task found $($comments[$i])"
											$TaskFound = $true
											# XML format for task
											# -------------------
											#	xmlns            : http://schemas.microsoft.com/windows/2004/02/mit/task
											#	version          : 1.1
											#	RegistrationInfo : RegistrationInfo
											#	Triggers         : Triggers
											#	Settings         : Settings
											#	Principals       : Principals
											#	Actions          : Actions
											#
											#	Triggers: $xml.Task.Triggers
											#	Actions: $xml.Task.Actions.Exec | select -ExpandProperty command

											if ($PrintXML) { $Comments[$i]; $Tasks[$i].outerXML }

											if ($OnlyTaskName)
											{
												if ($FoundTasks -ne "") { $FoundTasks += " ; " }

												$FoundTasks += "$($Comments[$i].Trim())"
											}
											else
											{
												$TaskInfo = "Name: `"$($Comments[$i].Trim())`""

												$TaskInfo += ", Author `"$($Tasks[$i].RegistrationInfo.Author)`""

												$TaskInfo += ", Enabled: `"$($Tasks[$i].Settings.Enabled)`""

												foreach ($exec in $Tasks[$i].Actions.Exec)
												{
													$TaskInfo += ", Command: `"$($exec | select -ExpandProperty command -ea ignore)`""
													$TaskInfo += ", Argument: `"$($exec | select -ExpandProperty arguments -ea ignore )`""
												}
												foreach ($com in $Tasks[$i].Actions.ComHandler)
												{
													$TaskInfo += ", ComHandler: `"$($com | select -ExpandProperty ClassId -ea ignore )`""
													$TaskInfo += ", Data: `"$($com.data.'#cdata-section')`""
												}
											} # print all information of a task
											if (!$OnlyTaskName) 
											{
												$FoundTasks += " ["+$TaskInfo+"] ;"
											}
										} # task found
									} # loop through all tasks
									if ($TaskFound)
									{
										$Status = "pass"
										$Reason = $FoundTasks
									}
									else
									{
										$Status = "fail"
										if (!$Reason) { $Reason = "Task not found" }
									}
								} # stdout not empty and psexec successfull
							} #RemoteRegistryStarted = true
							else
							{
								$Status = "fail"
								$Reason = "Error while enabling RemoteRegistry"
							}
						} #whatif
						else
						{
							$Status = "pass"
							$Reason = "Not executed - started with -WhatIf"
						}

						<# NOT USED - SCHTASKS IS USED DIRECTLY AGAINST REMOTE HOST
						try
						{
							if (!$IsLocalhost -and !$NoRemoteRegistry -and $RemoteRegistryStarted -or (!$IsLocalhost -and $WhatIfPassed))
							{
								Write-Verbose "Cleanup RemoteRegistry"
								$srr = Stop-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false -WhatIf:$WhatIfPassed
								$returnobject += $srr
								$drr = Disable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false -WhatIf:$WhatIfPassed
								$returnobject += $drr
							}
						}
						catch
						{
							Write-Verbose "Error while disabling RemoteRegistry"
							$Reason = "Error while disabling RemoteRegistry"
							$Status = "fail"
						}
						#>
					} #binary found

				} #UseExternal

			} #online

			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

		} #foreach target

	} #parameters are correct, process targets

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} #Get-ScheduledTask

#SCHTASKS/Run
Function Start-ScheduledTask()
{
	
}

#SCHTASKS/End
Function Stop-ScheduledTask()
{
	
}

#SCHTASKS/ENABLE
function Enable-ScheduledTask()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("External")]
		[string] $Method = "External",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[switch] $NoRemoteRegistry,

		[switch] $OnlineCheck = $true,

		[string] $SearchString

	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "SearchString $SearchString, WhatIf: $($PSBoundParameters.ContainsKey('WhatIf'))"
	Write-Verbose "Arguments: $Arguments"

	if (!$SearchString)
	{
 		$Reason = 'You have to provide a search string'
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
					$ret = Edit-ScheduledTask -Method wmi -ComputerName $target -SearchString $SearchString -TaskState "enable" -WhatIf:$PSBoundParameters.ContainsKey('WhatIf') -NoRemoteRegistry:$PSBoundParameters.ContainsKey('NoRemoteRegistry') -OnlineCheck:$false -Credential:$Credential
				}
				elseif ($Method -match "winrm")
				{
					$ret = Edit-ScheduledTask -Method winrm -ComputerName $target -SearchString $SearchString -TaskState "enable" -WhatIf:$PSBoundParameters.ContainsKey('WhatIf') -NoRemoteRegistry:$PSBoundParameters.ContainsKey('NoRemoteRegistry') -OnlineCheck:$false -Credential:$Credential
				}
				elseif ($Method -match "external")
				{
					$ret = Edit-ScheduledTask -Method External -ComputerName $target -SearchString $SearchString -TaskState "enable" -WhatIf:$PSBoundParameters.ContainsKey('WhatIf') -NoRemoteRegistry:$PSBoundParameters.ContainsKey('NoRemoteRegistry') -OnlineCheck:$false -Credential:$Credential
				}

				$ret | ? { $_.Function -match "Edit-ScheduledTask" } | % { $_.Function = $Function }
				$ret | ? { $_.Arguments -match "Edit-ScheduledTask" } | % { $_.Arguments = $Arguments }
				$returnobject += $ret
			}

		} #foreach targets

	} #parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"

} #Enable-ScheduledTask

#SCHTASKS/DISABLE
function Disable-ScheduledTask()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("External")]
		[string] $Method = "External",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[switch] $NoRemoteRegistry,

		[switch] $OnlineCheck = $true,

		[string] $SearchString

	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "SearchString $SearchString"
	Write-Verbose "Arguments: $Arguments"

	if (!$SearchString)
	{
 		$Reason = 'You have to provide a task name'
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
					$ret = Edit-ScheduledTask -Method wmi -ComputerName $target -SearchString $SearchString -TaskState "disable" -WhatIf:$PSBoundParameters.ContainsKey('WhatIf') -NoRemoteRegistry:$PSBoundParameters.ContainsKey('NoRemoteRegistry') -OnlineCheck:$false -Credential:$Credential
				}
				elseif ($Method -match "winrm")
				{
					$ret = Edit-ScheduledTask -Method winrm -ComputerName $target -SearchString $SearchString -TaskState "disable" -WhatIf:$PSBoundParameters.ContainsKey('WhatIf') -NoRemoteRegistry:$PSBoundParameters.ContainsKey('NoRemoteRegistry') -OnlineCheck:$false -Credential:$Credential
				}
				elseif ($Method -match "external")
				{
					$ret = Edit-ScheduledTask -Method external -ComputerName $target -SearchString $SearchString -TaskState "disable" -WhatIf:$PSBoundParameters.ContainsKey('WhatIf') -NoRemoteRegistry:$PSBoundParameters.ContainsKey('NoRemoteRegistry') -OnlineCheck:$false -Credential:$Credential
				}

				# change action description for return object that they match current
				# function and not generic edit function
				$ret | ? { $_.Function -match "Edit-ScheduledTask" } | % { $_.Function = $Function }
				$ret | ? { $_.Arguments -match "Edit-ScheduledTask" } | % { $_.Arguments = $Arguments }
				$returnobject += $ret

			} # online

		} #foreach targets

	} #parameters ok

	$returnobject
	Write-Verbose "Leaving $Function"

} #Disable-ScheduledTask

Function Edit-ScheduledTask()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("external")]
		[string] $Method = "external",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[switch] $NoRemoteRegistry,

		[boolean] $OnlineCheck = $true,

		[string] $SearchString,

		[ValidateSet("enable", "disable")]
		[string] $TaskState

	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()

	$Arguments = "SearchString: $SearchString, TaskState: $TaskState, OnlineCheck: $OnlineCheck"
	Write-Verbose $Arguments

	if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'])
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

	if (!$SearchString)
	{
 		$Reason = 'You have to provide a task name or a part from any part of the scheduled task (regex also possible)'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	elseif (!$TaskState)
	{
 		$Reason = 'You have to provide the required task state: Enable or Disable.'
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
					$Status = "fail"
					$Reason = "method not implemented yet"
				}
				elseif ($Method -match "winrm")
				{
					$Status = "fail"
					$Reason = "method not implemented yet"
				}
				elseif ($Method -match "external")
				{
					Write-Verbose "Using ExternalTools / Sysinternals"
					Write-Verbose "BinPath: $BinPath"
				
					if (!(Test-Path -Path "$BinPath\psexec.exe"))
					{
						$Status = "fail"
						$Reason = "Binary psexec not found."
					}
					else
					{
						<# NOT USED - SCHTASKS IS USED DIRECTLY AGAINST REMOTE HOST
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
						#>
						$RemoteRegistryStarted = $true

						if ($RemoteRegistryStarted -or $WhatIfPassed)
						{
							# todo add multiple task editing

							# Output of schtasks is written in OS language
							# therefore we use XML output which output is not written in OS language

							$TaskNameList = (Get-ScheduledTask -ComputerName $target -SearchString $SearchString -Method external -OnlyTaskName -WhatIf:$WhatIfPassed -NoRemoteRegistry:$false -OnlineCheck:$false | ? {$_.Function -match "Get-ScheduledTask"} | select -ExpandProperty Reason) -split " ; "

							Write-Verbose "Answer Get-ScheduledTask: $TaskNameList"

							if ($TaskNameList.Count -gt 1)
							{
								$Status = "fail"
								$Reason = "Multiple tasks found: $($TaskNameList -join ' ; ')"
							}
							elseif ($TaskNameList -match "Task not found")
							{
								$Status = "fail"
								$Reason = "Task not found"
							}
							elseif ($TaskNameList -or $WhatIfPassed)
							{
								if ($pscmdlet.ShouldProcess($target, "$TaskState tasks matches $SearchString"))
								{
									if ($target -match "localhost")
									{
										$proc = Start-Process schtasks.exe -commandline "/change /TN `"$TaskNameList`" /$TaskState"
									}
									else
									{
										#$proc = Start-Process psexec.exe -commandline "\\$target -accepteula -nobanner schtasks /change /TN `"$TaskNameList`" /$TaskState"
										$proc = Start-Process schtasks.exe -commandline "/S $target /change /TN `"$TaskNameList`" /$TaskState"
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

									if ($proc.stdout)
									{
										if ($proc.stdout -match "erfolgreich" -or $proc.stdout -match "successfull")
										{
											$Status = "pass"
											$Reason = "Task set to $TaskState"
										}
										else
										{
											$Status = "fail"
											$Reason = "Fail: $($proc.stdout)"
										}
									} # stdout has result
									else
									{
										$Status = "fail"
										$Reason = "Fail: Task found but $TaskState not working. Could be due to permissions."
									}
								} # whatif
								else
								{
									$Status = "pass"
									$Reason = "Not executed - started with -WhatIf"
								}
							} # task found
							elseif (!$TaskNameList)
							{
								$Status = "fail"
								$Reason = "Error in Get-ScheduledTask searching for $Name (taskname not found)"
							}
							else
							{
								$Status = "fail"
								$Reason = "Error: $TaskNameList"
							}
						} #RemoteRegistry started
						else
						{
							$Status = "fail"
							$Reason = "Error while enabling RemoteRegistry"
						}

						<# NOT USED - SCHTASKS IS USED DIRECTLY AGAINST REMOTE HOST
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
						#>

					} # binary found

				} #UseExternal

			} # host online

			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

		} #foreach target

	} # parameters ok

	$returnobject
	Write-Verbose "Leaving $Function"
}

#SCHTASKS/Delete
Function Remove-ScheduledTask()
{
	
}
