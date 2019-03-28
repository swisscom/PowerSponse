# Would also be possible through MMC and remote computer
Function Get-Certificate()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WinRM")]
		[string] $Method = "winrm",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $false,

		[string] $SearchString

	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()

	$Arguments = "SearchString: $SearchString"
	Write-Verbose $Arguments

	Write-Progress -Activity "Running $Function" -Status "Initializing..."

	if (!$SearchString)
	{
		$Status = "fail"
		$Reason = "No search string given"
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

			if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
			{
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
					if ($pscmdlet.ShouldProcess($target, "XXX"))
					{
						Write-Verbose "Using wmi with credentials"

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

					if ($pscmdlet.ShouldProcess($target, "Reading certificates with WinRM"))
					{
						if ($target -match "localhost")
						{
							$Certs = Get-ChildItem -Path Cert:\ -Recurse
						}
						else
						{
							try
							{
                                $params += @{
                                    'ea' = 'Stop'
                                }

                                if ($target -ne "localhost")
                                {
                                    $params += @{
                                        'ComputerName' = $target
                                        'SessionOption' = (New-PSSessionOption -NoMachineProfile)
                                    }
                                }

                                if ($Credential)
                                {
                                    $params += @{
                                        'Credential' = $Credential
                                    }
                                }

                                $params += @{
                                    'ScriptBlock' = { Get-ChildItem -Path Cert:\ -Recurse -ea SilentlyContinue}
                                }
                                $Certs = Invoke-Command @params
							}
							Catch
							{
								$Status = "fail"
								$Reason = "Exception raised: $($_.Exception.Message)"
							}
						}

                    	if ($Certs)
						{
							$Status = "pass"

                            $FoundCerts = $Certs | ?  { $_.PSParentPath -match "$SearchString" -or $_.FriendlyName -match "$SearchString" -or $_.Issuer -match "$SearchString" -or $_.Subject -match "$SearchString" }
                            $res = $FoundCerts | Select-Object -Property PSParentPath, FriendlyName, NotBefore, NotAfter, SerialNumber, ThumbPrint, Issuer, Subject, Version

							$Reason = $($res)
						}
						else
						{
							$Status = "fail"
							$Reason = "failed to retrieve certificates"
						}


										} #whatif
					else
					{
						$Status = "pass"
						$Reason = "Executed with -WhatIf"
					}
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
							$res = Enable-RemoteRegistry -Method external -ComputerName $target

							# check if remote registry service was enabled
							if ($res.status -match "pass")
							{
								Start-Service -ComputerName $target -Method external -Name "RemoteRegistry"
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

								# xxx todo add check for stdout
								if ($proc.stdout)
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
								Write-Verbose "Error while enabling RemoteRegistry"
								$Reason = "Error while enabling RemoteRegistry"
								$Status = "fail"
							}
						} # try enabling RemoteRegistry
						catch
						{
							Write-Verbose "Error while enabling RemoteRegistry"
							$Reason = "Error while enabling RemoteRegistry"
							$Status = "fail"
						}
						try
						{
							# Cleanup
							if ($RemoteRegistryStarted)
							{
								Write-Verbose "Cleanup RemoteRegistry"
								Stop-Service -ComputerName $target -Method external -Name "RemoteRegistry"
								Disable-RemoteRegistry -Method external -ComputerName $target
							}
						}
						catch
						{
							Write-Verbose "Error while disabling RemoteRegistry"
							#fix when process found but disabling failed, info accordi
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
}

Function Remove-Certificate()
{
	
}

