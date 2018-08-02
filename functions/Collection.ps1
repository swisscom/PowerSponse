function Get-Autoruns()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string[]] $ComputerName,
		[string] $ComputerList,
		[string] $OutputPath,
		[switch] $NoRemoteRegistry = $false
	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()
	$RemoteRegistryStarted = $false
	$WhatIfPassed = $false

	Write-Verbose "Using PsExec and Autorunsc.exe for collecting the logs."

	$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'])
	{
		$WhatIfPassed = $true
	}
	Write-Verbose "whatif: $WhatIfPassed"

	# without OutputPath given by user, use current dir
	if ($OutputPath)
	{
		if (!(test-path $OutputPath))
		{
			$Status = "fail"
			$Reason = "Path $OutputPath not reachable"

			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason
			$returnobject

			Write-Verbose "Leaving $($MyInvocation.MyCommand)"
			return
		}
	}
	else
	{
		$OutputPath = $pwd
	}

	Write-Verbose "Using OutputPath $OutputPath"

	foreach ($target in $targets)
	{
		Write-Progress -Activity "Running $Function" -Status "Checking connection to $target..."
		$IsLocalhost = ($target -match "localhost")

		if(!$IsLocalhost -and !$WhatIfPassed -and !(Test-Connection $target -count 1 -quiet))
		{
			$Status = "fail"
			$Reason = "$target offline"
			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -ComputerName $target
			Continue
		}

		# Enable and start RemoteRegistry if not already done by other functions
		if ($NoRemoteRegistry -or $IsLocalhost)
		{
			$RemoteRegistryStarted = $true
		}
		else
		{
			try
			{
				# Enable RemoteRegistry for psexec
				$err = Enable-RemoteRegistry -method external -ComputerName $target -WhatIf:$WhatIfPassed -OnlineCheck:$false
				$returnobject += $err
				$srr = Start-Service -ComputerName $target -method external -Name "RemoteRegistry" -WhatIf:$WhatIfPassed -OnlineCheck:$false
				$returnobject += $srr
				$RemoteRegistryStarted = ($srr.status -match "pass")
			}
			catch
			{
				$Status = "fail"
				$Reason = "Error while enabling RemoteRegistry"
				$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason
				Continue
			}
		} # Enabling RemoteRegistry

		if ($WhatIfPassed)
		{
			$RemoteRegistryStarted = $true
		}

		if ($pscmdlet.ShouldProcess($target, "Collecting autoruns"))
		{

			if ($RemoteRegistryStarted)
			{
				Write-Progress -Activity "Running $Function" -Status "Run autorunsc on $target..."
				# run psexec with autoruns
				#
				if ($IsLocalhost)
				{
					$AutorunsResult = (Start-Process -Binary $ModuleRoot\bin\autorunsc.exe -CommandLine "-nobanner -accepteula -a * -c -h -s *")
				}
				else
				{
					$AutorunsResult = (Start-Process -Binary PsExec.exe -CommandLine "-accepteula -nobanner \\$target -s -c -f $ModuleRoot\bin\autorunsc.exe -nobanner -accepteula -a * -c -h -s *")
				}

				if ($AutorunsResult.exitcode -eq 0)
				{
					# replace null bytes
					$AutorunsResult =  $AutorunsResult.stdout -replace "`0",""

					if ($target -match "localhost")
					{
						$FileName = "$($env:COMPUTERNAME)_v000.csv"
					}
					else
					{
						$FileName = "$($target)_v000.csv"
					}

					$FilePath = "$($OutputPath)\$FileName"
					Write-Verbose "Write file $FilePath"

					try
					{
						Set-Content -value $AutorunsResult -path $FilePath -ea stop
						$Status = "pass"
						$Reason = "$OutputPath;$FileName"
					}
					catch [UnauthorizedAccessException]
					{
						$Status = "fail"
						$Reason = "Error while writing to $FilePath - PermissionDenied"
					}
					catch
					{
						$Status = "fail"
						$Reason = "Error while writing to $FilePath"
					}
				} # psexec returns ok
				else
				{
					$Status = "fail"
					$Reason = "Error running autoruns on $target. Could be due to permissions."
				}
			} #RemoteRegistryStarted true
			else
			{
				$Status = "fail"
				$Reason = "Error while enabling RemoteRegistry"
			}
		} #without whatif
		else
		{
			$Status = "pass"
			$Reason = "Not executed - started with -WhatIf"
		} #whatif used

		# Stop and Disable RemoteRegistry
		if (!$IsLocalhost -and (!$NoRemoteRegistry -and $RemoteRegistryStarted) -or (!$NoRemoteRegistry -and $WhatIfPassed))
		{
			try
			{
				Write-Verbose "Cleanup RemoteRegistry"
				$srr = Stop-Service -ComputerName $target -method external -Name "RemoteRegistry" -WhatIf:$WhatIfPassed -OnlineCheck:$false
				$returnobject += $srr
				$drr = Disable-RemoteRegistry -method external -ComputerName $target -WhatIf:$WhatIfPassed -OnlineCheck:$false
				$returnobject += $drr
			}
			catch
			{
				$Status = "fail"
				$Reason = "Error while disabling RemoteRegistry"
			}
		}

		$returnobject += New-PowerSponseObject -Function $Function -ComputerName $target -Arguments $Arguments -Status $Status -Reason $Reason

	} # foreach target

	# returnobject with all powersponse objects
	$returnobject

	Write-Verbose "Leaving $($MyInvocation.MyCommand)"

} # Get-Autoruns

function Get-Sysmon()
{
	# todo
	# Use existing sysmon collection script
}
