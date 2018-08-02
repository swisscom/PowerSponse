<#

PowerSponse Output Object
-------------------------

Status = "fail"
Reason = "no process found"

$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

Example Output
--------------

PS> Get-Process -ProcessName calc -Method wmi | ft *

Time                Action      ComputerName Arguments         Status Reason
----                ------      ------------ ---------         ------ ------
09.01.2017 18:35:39 Get-Process localhost    ProcessName: calc fail   no process found

#>

Function Function-Template()
{
	# xxx add DefaultParameterSetName
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

		[switch] $NoRemoteRegistry,

		# XXX add function specific parameters here

	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()

	# XXX Add argument values (used for output object)
	$Arguments = "OnlineCheck: $OnlineCheck"
	Write-Verbose "Arguments: $Arguments"

	Write-Progress -Activity "Running $Function" -Status "Initializing..."

	# xxx add variables check here
	if (!VARIABLE_CHECK)
	{
		$Status = "fail"
		$Reason = ""
		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	# xxx if more than one check is needed
	elseif (!VARIABLE_CHECK)
	{
		$Status = "fail"
		$Reason = "both process name or process id given"
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
			Write-Progress -Activity "Running $Function" -Status "Processing $target..."

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
					Write-Verbose "Using WMI"

					if (($target -eq "localhost") -and $Credential)
					{
						$Status = "fail"
						$Reason = "localhost and WMI and credential not working"
						$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
						Continue
					}
					# xxx add whatif text
					if ($pscmdlet.ShouldProcess($target, "xXX"))
					{
						# xxx add WMI functionality here
						try
						{
							$res = Get-WmiObject XXXXX -ComputerName $target -Credential $Credential -ErrorAction Stop
						}
						catch
						{
							$Status = "fail"
							$Reason = "error while connecting to remote host"
						}

						if (!$res)
						{
							# xxx add reason for fail
							$Status = "fail"
							$Reason = ""
						}
						else
						{
							# xxx  process the output of WMI command
							$Status = "pass"
							$Reason = ""
						}
					} # whatif
				} # UseWMI
				elseif ($Method -match "winrm")
				{
					Write-Verbose "Using WinRM"
					# xxx add -whatif text
					if ($pscmdlet.ShouldProcess($target, "xxx"))
					{
						try
						{
							# xxx add winrm functionality
							$res = Microsoft.PowerShell.Management\get-process $ProcessName -ComputerName $target -Credential $credential
						}
						catch [XXX]
						{
							$Status = "fail"
							$Reason = ""
						}
						Catch
						{
							$Status = "fail"
							$Reason = ""
						}
						if (!$res)
						{
							$Status = "fail"
							$Reason = ""
						}
						else
						{
							$Status = "pass"
							$Reason = ""
						}
					} #whatif
				} #UseWinRM
				elseif ($Method -match "external")
				{
					Write-Verbose "Using ExternalTools / Sysinternals"
					Write-Verbose "BinPath: $BinPath"

					# xxx check required binaries
					if (!(Test-Path -Path "$BinPath\xxx.exe"))
					{
						$Status = "fail"
						$Reason = ""
					}
					elseif (!(Test-Path -Path "$BinPath\psservice.exe"))
					{
						$Status = "fail"
						$Reason = ""
					}
					else
					{
						# Enable RemoteRegistry for the target
						try
						{
							$res = Enable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false

							# check if remote registry service was enabled
							if ($res.status -match "pass")
							{
								Start-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false
								$RemoteRegistryStarted = $true

								# xxx run the required binary
								$proc = Start-Process "binary.exe" "<command line>"

								if ($proc.ExitCode -eq 0)
								{
									Write-Verbose "Successfully executed XXXX on $target"
								}
								else
								{
									Write-Verbose  "Error while running XXXX on $target"
									Write-Verbose "stdout"
									Write-Verbose $proc.stdout
									Write-Verbose "stderr"
									Write-Verbose $proc.stderr
								}

								# process command output
								if ($proc.stdout ...)
								{
									$Status = "fail"
									$Reason = ""
								}
								else
								{
									$Status = "pass"
									$Reason = $proc.stdout
								}
							} # RemoteRegistry enabled
							else
							{
								$Reason = "Error while enabling RemoteRegistry"
								$Status = "fail"
							}
						} # try enabling RemoteRegistry
						catch
						{
							$Reason = "Error while enabling RemoteRegistry"
							$Status = "fail"
						}
						try
						{
							# Cleanup
							if ($RemoteRegistryStarted)
							{
								Write-Verbose "Cleanup RemoteRegistry"
								Stop-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false
								Disable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false
							}
						}
						catch
						{
							#fix when process found but disabling failed, info accordingly
							$Reason = "Error while disabling RemoteRegistry"
							$Status = "fail"
						}

					} # external tools found

				} # UseExternal

			} # host online

			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

		} # each target

	} # parameters ok

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} # Function-Template
