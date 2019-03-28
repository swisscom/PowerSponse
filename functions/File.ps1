Function Remove-File()
{

}


Function Remove-Directory()
{

}


# todo -whatif
# check fail saviness
Function Remove-FileSystemObject()
{

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

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

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
 		$Reason = 'You have to provide a file path path with -Path'
		$Status = "fail"
 		$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
	}
	else
    {
		$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	    Find-FileSystemObject -targets $targets -Method:$Method -File -Path:$Path -Recurse:$Recurse -Regex:$Regex
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

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

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

	    Find-FileSystemObject -targets $targets -Method:$Method -Path:$Path -Recurse:$Recurse -Regex:$Regex
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

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

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
                    Write-Verbose "Using WinRM - File: $Path"

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
                            'ScriptBlock' = {param($p1,$p2,$p3) Microsoft.PowerShell.Management\get-childitem -Path "$p1" `
                                                                                                      -Recurse:$(if($p2){$true}else{$false})`
                                                                                                      -File:$(if($p3){$true}else{$false})`
                                                                                                      -Directory:$(if($p3){$false}else{$true})`
                                                                                                      -ea SilentlyContinue}
                            'ArgumentList' = $Path,$Recurse,$File
                        }

                        $ret = invoke-command @params

                        if ($Regex)
                        {
                            Write-Verbose "filter with regex $Regex"
                            $ret = $ret | ? { $_.FullName -match "$Regex" }
                        }

                        if (!$ret)
                        {
                            $Status = "fail"
                            $Reason = "no files found with $Path and regex `"$Regex`""
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
