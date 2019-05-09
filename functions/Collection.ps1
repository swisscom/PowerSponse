function Get-Autoruns()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string[]] $ComputerName,
		[string] $ComputerList,
		[string] $OutputPath,
		[switch] $NoRemoteRegistry = $false,
		[string] $FilenamePostfix = "_v000"
	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$returnobject = @()
	$RemoteRegistryStarted = $false
	$WhatIfPassed = $false

	Write-Verbose "Using PsExec and autorunsc.exe for collecting the autoruns logs."

	$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'].ispresent)
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
		$IsLocalhost = ($target -match "localhost")

		if ($pscmdlet.ShouldProcess($target, "Collecting autoruns"))
		{

			Write-Progress -Activity "Running $Function" -Status "Collecting autoruns on $target..."

			if ($IsLocalhost)
			{
				$AutorunsResult = (Start-Process -Binary $ModuleRoot\bin\autorunsc.exe -CommandLine "-nobanner -accepteula -a * -c -h -s *")
			}
			else
			{
				$params = @{
					'ComputerName'= $target;
					'Program' =  "$ModuleRoot\bin\autorunsc.exe";
					'CommandLine'= "-nobanner -accepteula -a * -c -h -s *";
					'CopyProgramToRemoteSystem' = $true;
					'ForceCopyProgramToRemoteSystem' = $true
				}
				$PowerSponseObjects, $ReturnValue = Invoke-PsExec @params

				$returnobject += $PowerSponseObjects

				$AutorunsResult = $ReturnValue
			}

			if ($AutorunsResult.exitcode -eq 0)
			{
				# replace null bytes
				$AutorunsResult =  $AutorunsResult.stdout -replace "`0",""

				$FileName = "$($target)$FilenamePostfix.csv"
				$FilePath = "$($OutputPath)\$FileName"
				Write-Verbose "Write file $FilePath"

				try
				{
					Set-Content -value $AutorunsResult -path $FilePath -ea stop
					$Status = "pass"
					$Reason = "$OutputPath\$FileName"
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
			} # executing autoruns returns 0
			else
			{
				$Status = "fail"
				$Reason = "Error running autoruns on $target. Could be due to permissions."
			} # executing autoruns failed
		} #no whatif given
		else
		{
			$Status = "pass"
			$Reason = "Not executed - started with -WhatIf"
		} #whatif used

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
