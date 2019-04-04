Function Remove-File()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

        [ValidateSet("WinRM")]
        [string] $Method = "WinRM",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $Path,
		[switch] $Recurse,
		[string] $Regex
	)

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

    $WhatIfPassed = $false
	$returnobject = @()
    $ret = ""
	$Arguments = $Path

    if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'])
    {
        $WhatIfPassed = $true
    }
    Write-Verbose "whatif: $WhatIfPassed"

	if (!($Path))
	{
 		$Reason = 'You have to provide a file path path with -Path'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
    {
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	    Remove-FileSystemObject -targets $targets -Method:$Method -File -Path:$Path -Recurse:$Recurse -Regex:$Regex -WhatIf:$WhatIfPassed -Credential:$Credential
	}

	$returnobject

	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}


Function Remove-Directory()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

        [ValidateSet("WinRM")]
        [string] $Method = "WinRM",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $Path,
		[switch] $Recurse,
		[string] $Regex
	)

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

    $WhatIfPassed = $false
	$returnobject = @()
    $ret = ""
	$Arguments = $Path

    if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'])
    {
        $WhatIfPassed = $true
    }
    Write-Verbose "whatif: $WhatIfPassed"

	if (!($Path))
	{
 		$Reason = 'You have to provide a file path path with -Path'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
    {
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	    Remove-FileSystemObject -targets $targets -Method:$Method -Path:$Path -Recurse:$Recurse -Regex:$Regex -WhatIf:$WhatIfPassed -Credential:$Credential
	}

	$returnobject

	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}


Function Remove-FileSystemObject()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param
	(
		[string[]] $targets,

        [ValidateSet("WinRM")]
        [string] $Method = "WinRM",

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $Path,
		[switch] $Recurse,
		[string] $Regex,
		[switch] $File,

        [boolean] $OnlineCheck = $false
	)

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

	$returnobject = @()
    $ret = ""
    $items = ""
    $WhatIfPassed = ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'])

	$Arguments = "Path: $Path, File: $File, Recurse: $Recurse, Regex: $Regex, WhatIfPassed: $WhatIfPassed"
    $Arguments += ", Onlinecheck: $OnlineCheck"

	if (!($Path))
	{
 		$Reason = 'You have to provide a file path path with Path'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		foreach ($target in $targets)
		{
            $params = @{}
            $items = ""
            $ret = ""

            Write-Progress -Activity "Running $Function" -Status "Processing $Path with regex `"$Regex`" on $target..."

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
                    Write-Verbose "Using WinRM - File: $Path, Regex: $Regex"

                    $returnobject_temp = Find-FileSystemObject -File:$File -target $target -Method winrm -Path:$Path -Recurse:$Recurse -Regex:$Regex -Credential:$Credential
                    $returnobject += $returnobject_temp

                    $items = $null

                    if ($returnobject_temp -and $returnobject_temp.reason -notmatch "no ")
                    {
                        $items = $returnobject.reason.fullname
                    }
                    else
                    {
                        $Status = "pass"
                        $Reason = "Nothing to remove."
                        $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
                        Continue
                    }

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

                        if ($WhatIfPassed)
                        {
                            $Status = "pass"
                            $Reason = "WhatIf passed - nothing removed. See output of find function about removed items."
 			                $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
                            Continue
                        }

                        $params += @{

                            'ScriptBlock' = { `
                                param($p1) $p1 | % { $item = $_; try { Microsoft.PowerShell.Management\Remove-Item `
                                   -path "$item" `
                                   -Recurse `
                                   -force `
                                   -WhatIf:$false `
                                   -ea Stop} `
                                   catch [System.Management.Automation.ItemNotFoundException] { "INFO - $item - $($_.Exception.Message) This is likely caused by using the -recurse option and when attempting to remove a child item after the parent item was removed already." } `
                                   catch { "ERROR - $item - $($_.Exception.Message)" } `
                                }
                            }
                            'ArgumentList' = (,$items)
                        }

                        $ret = invoke-command @params

                        if (!($ret))
                        {
                            $Status = "pass"
                            $Reason = "All files or directories removed. See output of find function about removed items."
                        }
                        elseif ($ret -match "ERROR")
                        {
                            $Status = "fail"
                            $Reason += $ret
                        }
                        else
                        {
                            $Status = "pass"
                            $Reason = "Remove command return with following information: "
                            $Reason += $ret
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
}


Function Rename-Directory()
{

}


Function Rename-File()
{

}


Function Find-File()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

        [ValidateSet("WinRM")]
        [string] $Method = "WinRM",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $Path,
		[switch] $Recurse,
		[string] $Regex
	)

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

	$returnobject = @()

	$Arguments = $Path

	if (!($Path))
	{
 		$Reason = 'You have to provide a file path path with -Path'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
    {
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	    Find-FileSystemObject -targets $targets -Method:$Method -File -Path:$Path -Recurse:$Recurse -Regex:$Regex -Credential:$Credential
	}

	$returnobject

	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}


Function Find-Directory()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

        [ValidateSet("WinRM")]
        [string] $Method = "WinRM",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $Path,
		[switch] $Recurse,
		[string] $Regex
	)

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

	$returnobject = @()
    $ret = ""

	$Arguments = $Path

	if (!($Path))
	{
 		$Reason = 'You have to provide a path with -Path'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
    {
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	    Find-FileSystemObject -targets $targets -Method:$Method -Path:$Path -Recurse:$Recurse -Regex:$Regex -Credential:$Credential

	}

	$returnobject

	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}


Function Find-FileSystemObject()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param
	(
		[string[]] $targets,

        [ValidateSet("WinRM")]
        [string] $Method = "WinRM",

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[string] $Path,
		[switch] $Recurse,
		[string] $Regex,

		[switch] $File
	)

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

	$returnobject = @()
    $ret = ""

	$Arguments = "Path: $Path, File: $File, Recurse: $Recurse, Regex: $Regex"

	if (!($Path))
	{
 		$Reason = 'You have to provide a file path path with Path'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
	{
		foreach ($target in $targets)
		{
            $params = @{}
            $ret = ""

            Write-Progress -Activity "Running $Function" -Status "Processing $Path with regex `"$Regex`" on $target..."

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
                    Write-Verbose "Using WinRM - File: $Path, Regex: $Regex"

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

                        if ($File -and $Recurse)
                        {
                            $params += @{
                                'ScriptBlock' = {param($p1,$p2,$p3) Microsoft.PowerShell.Management\get-childitem -Path "$p1" `
                                                                                                      -Recurse `
                                                                                                      -File `
                                                                                                      -force `
                                                                                                      -ea SilentlyContinue }
                                'ArgumentList' = $Path
                            }
                        }
                        elseif ($File)
                        {
                            $params += @{
                                'ScriptBlock' = {param($p1,$p2,$p3) Microsoft.PowerShell.Management\get-item -Path "$p1" `
                                                                                                      -ea SilentlyContinue `
                                                                                                      -force `
                                                                                                      | ? {$_.mode -notmatch "d.*"}}
                                'ArgumentList' = $Path
                            }
                        }
                        elseif (!($File) -and $Recurse)
                        {
                            $params += @{
                                'ScriptBlock' = {param($p1,$p2,$p3) Microsoft.PowerShell.Management\get-childitem -Path "$p1" `
                                                                                                      -Recurse `
                                                                                                      -Directory `
                                                                                                      -force `
                                                                                                      -ea SilentlyContinue}
                                'ArgumentList' = $Path
                            }
                        }
                        elseif (!($File))
                        {
                            $params += @{
                                'ScriptBlock' = {param($p1,$p2,$p3) Microsoft.PowerShell.Management\get-item -Path "$p1" `
                                                                                                      -ea SilentlyContinue `
                                                                                                      -force `
                                                                                                      | ? {$_.mode -match "d.*"}}
                                'ArgumentList' = $Path
                            }
                        }
                        else
                        {
                            throw "that should not happen - switch without the truth... file an issue with your command on Github."
                        }

                        $ret = invoke-command @params

                        if ($Regex)
                        {
                            Write-Verbose "filter with regex $Regex"
                            $ret = $ret | ? { $_.FullName -match "$Regex" }
                        }

                        if (!$ret)
                        {
                            $Status = "pass"
                            $Reason = "no $(if ($File) {"files"}else{"folders"}) found with $Path and regex `"$Regex`""
                        }
                        else
                        {
                            $Status = "pass"
                            $Reason = @()

                            foreach ($proc in $ret)
                            {
                                $info=[ordered]@{
                                    FullName=$proc.FullName
                                    CreationTime=$proc.CreationTime
                                    LastWriteTime=$proc.LastWriteTime
                                    Length=$proc.Length
                                }
                                $Reason += New-Object PSObject -Property $info
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

    if (!(Test-Path -Path "$BinPath\handle.exe"))
    {
        $Status = "fail"
        $Reason = "Binary handle.exe not found in bin path, see <modulepath>\bin\."
        $returnobject += New-PowerSponseObject -Function $Action -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
    }
	elseif (!$ProcessName -and !$ProcessPid)
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
