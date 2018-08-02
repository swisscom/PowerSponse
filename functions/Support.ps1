Function Get-Target()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string[]] $ComputerName,
		[string] $ComputerList
	)

	$targets = @()

	if (!$ComputerName -and !$ComputerList)
	{
		# if no target is defined, use localhost
		"localhost"
		return
	}

	#read all UNIQUE targets from ComputerName
	if ($ComputerName)
	{
		$targets += $ComputerName | Select-Object -Unique
	} #ComputerName

	#read all UNIQUE targets from ComputerList
	if ($ComputerList)
	{
		if (Test-Path $ComputerList)
		{
			$c = get-content $ComputerList
			if ($c -ne "" -and $c -ne $null)
			{
				$targets += $c | Select-Object -unique
			}
		}
		else
		{
			Throw [System.IO.FileNotFoundException] "File $ComputerList not found"
		}
	} #ComputerList
		
	if (!$targets -or $targets -eq "" -or $targets -eq $null)
	{
		# if no target is defined, use localhost
		"localhost"
	}
	else
	{
		# otherwise give only unique entries back
		# sort -unique would work too but changes the order
		$targets | % {$_.tolower()} | Select-Object -unique
	} # targets available

} #Get-Target

Function Enable-PSRemoting()
{

}

Function Disable-PSRemoting()
{
	
}

Function Enable-RemoteRegistry()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI", "WinRM", "External")]
		[string] $Method = "wmi",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[switch] $OnlineCheck = $true
	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "OnlineCheck: $OnlineCheck"
	Write-Verbose "Arguments: $Arguments"

	$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	foreach ($target in $targets)
	{
		Write-Progress -Activity "Running $Function" -Status "Processing $target..."
		if ($pscmdlet.ShouldProcess($target, "Enable RemoteRegistry"))
		{
			if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
			{
				$Status = "fail"
				$Reason = "offline"
			}
			else
			{
				if ($Method -match "wmi")
				{
					$res = Enable-Service -ComputerName $target -Credential $Credential -Name "RemoteRegistry" -Method wmi -StartupType manual -OnlineCheck:$false
				}
				elseif ($Method -match "winrm")
				{
					$res = Enable-Service -ComputerName $target -Name "RemoteRegistry" -Method winrm -StartupType manual -OnlineCheck:$false
				}
				elseif ($Method -match "external")
				{
					$res = Enable-Service -ComputerName $target -Name "RemoteRegistry" -Method external -StartupType manual -OnlineCheck:$false
				}
				$Status=$res.Status
				$Reason=$res.Reason
			}
			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
		}
	}

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}

Function Disable-RemoteRegistry()
{
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='Default')]
	param
	(
		[string[]] $ComputerName,

		[string] $ComputerList,

		[ValidateSet("WMI", "WinRM", "External")]
		[string] $Method = "wmi",

		[string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

		[System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

		[System.Management.Automation.PSCredential] $Credential=$Null,

		[switch] $OnlineCheck = $true
	)

	$returnobject = @()

	$Function = $MyInvocation.MyCommand
	Write-Verbose "Entering $Function"

	$Arguments = "OnlineCheck: $OnlineCheck"
	Write-Verbose "Arguments: $Arguments"

	$res = $null

	$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	foreach ($target in $targets)
	{
		Write-Progress -Activity "Running $Function" -Status "Processing $target..."
		if ($pscmdlet.ShouldProcess($target, "Disable RemoteRegistry"))
		{
			if ($OnlineCheck -and !(Test-Connection $target -Quiet -Count 1))
			{
				Write-Verbose "$target is offline"
				$Status = "fail"
				$Reason = "offline"
			}
			else
			{
				if ($Method -match "wmi")
				{
					$res = Disable-Service -ComputerName $target -Credential $Credential -Name "RemoteRegistry" -Method wmi -OnlineCheck:$false
				}
				elseif ($Method -match "winrm")
				{
					$res = Disable-Service -ComputerName $target -Name "RemoteRegistry" -Method winrm -OnlineCheck:$false
				}
				elseif ($Method -match "external")
				{
					$res = Disable-Service -ComputerName $target -Name "RemoteRegistry" -Method external -OnlineCheck:$false
				}
				$Status=$res.Status
				$Reason=$res.Reason
			}
			$returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
		}
	}

	$returnobject
	Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}

# builds a PowerSponse object with the supplied informaiton
function New-PowerSponseObject()
{
	param (
		[string] $Function = "",
		[string] $ComputerName = "",
		[string] $Arguments = "",
		[string] $Status = "",
		[object[]] $Reason = ""
	)
	$info=[ordered]@{
		Time=(get-date).tostring()
		Function=$Function
		ComputerName=$ComputerName
		Arguments=$Arguments
		Status=$Status
		Reason=$Reason
	}
	New-Object PSObject -Property $info
}
