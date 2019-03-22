# todo allow searching for multiple files, e.g. *.tmp within %temp%
# todo problem with environment variables and expansion
Function Find-File()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

        [ValidateSet("WinRM")]
        [string] $Method = "WinRM",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $File

	)

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

	$returnobject = @()
    $ret = ""

	$Arguments = $File

	if (!$File)
	{
 		$Reason = 'You have to provide a file path with -File'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		foreach ($target in $targets)
		{
            Write-Progress -Activity "Running $Function" -Status "Processing $File on $target..."

            if (!(Test-Connection $target -Quiet -Count 1))
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
                    Write-Verbose "Using WinRM - File: $File"

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
                            'ScriptBlock' = {param($p1) Microsoft.PowerShell.Management\get-childitem -Path "$p1" `
                                                                                                      -File `
                                                                                                      -ea SilentlyContinue}
                            'ArgumentList' = $File
                        }

                        $ret = invoke-command @params

                        if (!$ret)
                        {
                            $Status = "fail"
                            $Reason = "file not found"
                        }
                        else
                        {
                            $Status = "pass"
                            $Reason = @()

                            foreach ($proc in $ret)
                            {
                                $Reason += "FullName: $($proc.FullName) ; CreationTime: $($proc.CreationTime) ; LastWriteTime: $($proc.LastWriteTime), Length: $($proc.Length)"
                            }
                        }
                    }
                    catch
                    {
                        $Status = "fail"
                        $Reason = "$($_.Exception.Message)"
                    }
                }
                elseif ($Method -match "external")
                {
                    $Status = "fail"
                    $Reason = "method not implemented yet"
                }
            }

 			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

		} #foreach target
	} #parameters are correct, process targets

	$returnobject

	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} #Remove-File

Function Remove-File()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='ExternComputerName')]
	param
	(
		[Parameter(ParameterSetName='CredentialWinRMComputerName',Position=0)]
		[Parameter(ParameterSetName='CredentialWMIComputerName',Position=0)]
		[Parameter(ParameterSetName='ExternComputerName', Position=0)]
		[ValidateNotNullOrEmpty ()]
		[string[]] $ComputerName="empty",

		[Parameter(ParameterSetName='CredentialWinRMComputerList',Mandatory=$true)]
		[Parameter(ParameterSetName='CredentialWMIComputerList',Mandatory=$true)]
		[Parameter(ParameterSetName='ExternComputerList', Mandatory=$true)]
		[ValidateNotNullOrEmpty ()]
		[string] $ComputerList = "empty",

		[Parameter(ParameterSetName='SessionWMI',Mandatory=$true,Position=0)]
		[Parameter(ParameterSetName='SessionWinRM',Mandatory=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[Parameter(ParameterSetName='CredentialWinRMComputerList',Mandatory=$false)]
		[Parameter(ParameterSetName='CredentialWMIComputerList',Mandatory=$false)]
		[Parameter(ParameterSetName='CredentialWinRMComputerName',Mandatory=$false)]
		[Parameter(ParameterSetName='CredentialWMIComputerName',Mandatory=$false)]
		[System.Management.Automation.PSCredential] $Credential=$Null,

		[Parameter(ParameterSetName='ExternComputerList')]
		[Parameter(ParameterSetName='ExternComputerName')]
		[ValidateNotNullOrEmpty ()]
		[Switch] $UseExternal,

		[Parameter(ParameterSetName='ExternComputerList',Mandatory=$false)]
		[Parameter(ParameterSetName='ExternComputerName',Mandatory=$false)]
		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[Parameter(ParameterSetName='CredentialWinRMComputerList')]
		[Parameter(ParameterSetName='CredentialWinRMComputerName')]
		[Parameter(ParameterSetName='SessionWinRM')]
		[Switch] $UseWinRM,

		[Parameter(ParameterSetName='CredentialWMIComputerList')]
		[Parameter(ParameterSetName='CredentialWMIComputerName')]
		[Parameter(ParameterSetName='SessionWMI')]
		[ValidateNotNullOrEmpty ()]
		[Switch] $UseWMI,

		[Parameter(ParameterSetName='ExternComputerList')]
		[Parameter(ParameterSetName='ExternComputerName')]
		[switch] $NoRemoteRegistry,

		[string] $Name

	)

	Write-Verbose "Entering $($MyInvocation.MyCommand)"

	throw "not implemented"

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "Filepath $FileName"
	Write-Verbose "Arguments $Arguments"

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

	if (!$FileName)
	{
 		$Reason = 'You have to provide a file path (-FileName)'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Action -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		$targets = Get-Target $PSCmdlet.ParameterSetName $ComputerName $ComputerList

		[regex]$RegexWildcards = "\*|%|_|\?"

		foreach ($target in $targets)
		{
			if ($UseWMI)
			{
				# use find file first -> regex search
				if ($pscmdlet.ShouldProcess($target, "Find file `"$FileName`""))
				{
					$Filter = "Name = '$("$FileName".replace("\", "\\"))'"
					# check if regex is used
					if ($Filter -match $RegexWildcards)
					{
						$Filter = ($Filter -replace "="," LIKE ")
						$Filter = ([Management.Automation.WildcardPattern]$Filter).ToWql()
						Write-Verbose `"$Filter`"
					}
					$ret = Get-WmiObject -Class CIM_Datafile -Filter $Filter -Credential $Credential -ComputerName $target -ea Stop
					if ($ret)
					{
						Write-Verbose "File found: $($ret.name)"
					}
					else
					{
						Write-Verbose "file not found"
					}
				}
				# https://www.petri.com/using-powershell-and-wmi-to-find-folders-by-file-type
				if ($pscmdlet.ShouldProcess($target, "Remove file `"$FileName`""))
				{
					#enable
 					#$del = $ret.Delete()
					if($del -and $del.returnvalue -eq 0)
					{
						$Status = "pass"
						$Reason = "File removed"
					}
					elseif($del -and $del.returnvalue -eq 2)
					{
						$Status = "fail"
						$Reason = "Access denied"
					}
					else
					{
						$Status = "fail"
						$Reason = "File not removed"
					}
				}
			} #wmi
			elseif ($UseWinRM)
			{
				$Status = "fail"
				$Reason = "method not implemented yet"
			}
			elseif ($UseExternal)
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
					# RemoteRegistry is needed for PsExec
					try
					{
						if (!$NoRemoteRegistry)
						{
							# Enable RemoteRegistry for psexec
							$err = Enable-RemoteRegistry -method external -ComputerName $target
							$returnobject += $err
							$srr = Start-Service -ComputerName $target -method external -Name "RemoteRegistry"
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

					if ($pscmdlet.ShouldProcess($target, "$Action `"$FilePath\$FileName`""))
					{
						if ($RemoteRegistryStarted -or $WhatIfPassed)
						{
							# Output of schtasks is written in OS language
							# therefore we use XML output which is not written in OS language
							$pinfo = New-Object System.Diagnostics.ProcessStartInfo
							$pinfo.FileName = "$BinPath\psexec.exe"
							$pinfo.RedirectStandardError = $true
							$pinfo.RedirectStandardOutput = $true
							$pinfo.UseShellExecute = $false
							# todo
							#$pinfo.Arguments = "\\$target -accepteula -nobanner cmd /C rm `"$FilePath\$FileName`""
							$p = New-Object System.Diagnostics.Process
							$p.StartInfo = $pinfo
							$p.Start() | Out-Null
							# todo fix timeout
							$retP = $p.WaitForExit(2000)
							$stdout = $p.StandardOutput.ReadToEnd()
							$stderr = $p.StandardError.ReadToEnd()

							if ($p.ExitCode -eq 0)
							{
								Write-Verbose "Successfully executed PsExec on $target"
							}
							else
							{
								$Status = "fail"
								$Reason = "Error while running PsExec on $target"
								Write-Verbose "stdout"
								Write-Verbose $stdout
								Write-Verbose "stderr"
								Write-Verbose $stderr
							}

							if ($stdout -and ($p.ExitCode -eq 0))
							{
								# valid response - response from PsExec
								$Status = "todo"
								$Reason = "not implemented yet"
							}
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

					try
					{
						if (!$NoRemoteRegistry -and $RemoteRegistryStarted -or $WhatIfPassed)
						{
							Write-Verbose "Cleanup RemoteRegistry"
							$srr = Stop-Service -ComputerName $target -method external -Name "RemoteRegistry"
							$returnobject += $srr
							$drr = Disable-RemoteRegistry -method external -ComputerName $target
							$returnobject += $drr
						}
					}
					catch
					{
						Write-Verbose "Error while disabling RemoteRegistry"
						$Reason = "Error while disabling RemoteRegistry"
						$Status = "fail"
					}
				} #binary found
			} #UseExternal

 			$returnobject += New-PowerSponseObject -Function $Action -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
		} #foreach target
	} #parameters are correct, process targets

	if (!$WhatIfPassed)
	{
		$returnobject
	}
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} #Remove-File

Function Rename-File()
{

}

# todo see Find-File
Function Find-Directory()
{

}

Function Rename-Directory()
{

}

Function Remove-Directory()
{

}

function Get-FileHandle()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='ByProcessName')]
	param
	(
		[Parameter(ParameterSetName='ByProcessPid')]
		[Parameter(ParameterSetName='ByProcessName')]
		[string[]] $ComputerName,

		[Parameter(ParameterSetName='ByProcessPid')]
		[Parameter(ParameterSetName='ByProcessName')]
		[string] $ComputerList,

		[Parameter(ParameterSetName='ByProcessPid')]
		[Parameter(ParameterSetName='ByProcessName')]
		[ValidateSet("external")]
		[string] $Method = "external",

		[Parameter(ParameterSetName='ByProcessPid')]
		[Parameter(ParameterSetName='ByProcessName')]
		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[Parameter(ParameterSetName='ByProcessPid')]
		[Parameter(ParameterSetName='ByProcessName')]
		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[Parameter(ParameterSetName='ByProcessPid')]
		[Parameter(ParameterSetName='ByProcessName')]
		[System.Management.Automation.PSCredential] $Credential=$Null,

		[boolean] $OnlineCheck = $true,

		[Parameter(ParameterSetName='ByProcessName')]
		[string] $ProcessName,

		[Parameter(ParameterSetName='ByProcessPid')]
		[int] $ProcessPid,

		[Switch] $HandlesByProcessName

	)

	$Action = $MyInvocation.MyCommand
	Write-Verbose "Entering $Action"

	$returnobject = @()

	$Arguments = "ProcessName: $ProcessName, ProcessPid: $ProcessPid"

	Write-Progress -Activity "Running $Action" -Status "Initializing..."

	if (!$ProcessName -and !$ProcessPid)
	{
		$Status = "fail"
		$Reason = "specify ProcessName or ProcessPid"
		$returnobject += New-PowerSponseObject -Function $Action -Status $Status -Reason $Reason -Arguments $Arguments
	}
	# if all parameters are correctly supplied
	else
	{
		# build target list based on parameters
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

		# process every target
		foreach ($target in $targets)
		{
			Write-Progress -Activity "Running $Action" -Status "Checking connection to $target..."

			if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
			{
				Write-Verbose "$target is offline"
				$Status = "fail"
				$Reason = "offline"
				$returnobject += New-PowerSponseObject -Function $Action -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
			}
			else
			{
				if (($target -eq "localhost") -and $Credential)
				{
					$Status = "fail"
					$Reason = "localhost and WMI and credential not working"
					$returnobject += New-PowerSponseObject -Function $Action -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
					Continue
				}

				# todo
				# enable RemoteRegistry
				# start RemoteRegistry
				
				if ($ProcessName)
				{
					$ret = Get-Process -ProcessName:$ProcessName -OnlyProcessName:$(if ($HandlesByProcessName){$HandlesByProcessName}) -OnlyPid:$(if (!$HandlesByProcessName) {!$HandlesByProcessName}) -ComputerName $target -Credential $Credential -OnlineCheck:$false | select -ExpandProperty reason
				}
				else
				{
					$ret = Get-Process -ProcessPid:$ProcessPid -OnlyProcessName:$(if ($HandlesByProcessName){$HandlesByProcessName}) -OnlyPid:$(if (!$HandlesByProcessName) {!$HandlesByProcessName}) -ComputerName $target -Credential $Credential -OnlineCheck:$false | select -ExpandProperty reason
				}

				if ($ret)
				{
					foreach ($pid in $ret)
					{
						Write-Progress -Activity "Running $Action" -Status "Collecting handles for $pid on $target..."
						Write-Verbose "Processing Pid $pid"
						if ($target -match "localhost")
						{
							$handles = Start-Process handle.exe -CommandLine "-nobanner -accepteula -p $pid"
						}
						else
						{
							$handles = Start-Process handle.exe -CommandLine "-nobanner -accepteula \\$target -p $pid"
						}
						if ($handles.ExitCode -eq 0)
						{
							$status = "pass"
							$reason = $handles.stdout
						}
						else
						{
							$status = "fail"
							$reason = $handles.stderr
						}
					}
				}
				else
				{
					$Status = "fail"
					$Reason = "error running handle.exe on $target"
				}
				
				$returnobject += New-PowerSponseObject -Function $Action -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
				
				# todo
				# stop RemoteRegistry
				# disable RemoteRegistry
				
			}
		}
	}

	$returnobject

	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}
