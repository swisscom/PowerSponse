<#
The MIT License (MIT)

Copyright © 2018 Swisscom (Schweiz) AG

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

#region PowerSponse

#region CONTRIBUTING
<#

See CONSTRIBUTING.md

Enable new Function
  1. Add function to Export-ModuleMember at the bottom of this file
  2. Add function to FunctionsToExport in the .psd1 file
  3. Add new function to repository that Invoke-PowerSponse can handle it (Repository.ps1)
#>
#endregion

Function Invoke-PowerSponse()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string]
		$RuleFile = $(throw "you have to provide a rule"),

		[string[]]
		$ComputerName,

		[string]
		$ComputerList,

		[boolean]
		$OnlineCheck = $true,

		[switch]
		$IgnoreMissing,

		[switch]
		$PrintCommand
	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "$Function Entering $Function"

	$ret = @()

	Write-Verbose "$Function OnlineCheck: $OnlineCheck"

	Write-Progress -Activity "Running $Function" -Status "Initializing..."

	$ParsedRule = Get-PowerSponseRule -RuleFile $RuleFile

	$Arguments="OnlineCheck: $OnlineCheck, RuleFile: $RuleFile"
	
	# Todo Check custom local repository defintion (overwrite defaults)

	$MissingActions = @()
	if (!$IgnoreMissing)
	{
	  foreach ($Rule in $ParsedRule)
	  {
		  $Actions = $Rule.Action

		  foreach ($Action in $Actions)
		  {
			  $ActionName = $Action.type

			  if (!$Script:Repository.$ActionName)
			  {
				  $Status="fail"
				  $MissingActions += $ActionName
				  Write-Verbose $ActionName
			  }
		  }
	  }

	  if ($MissingActions)
	  {
		$Reason="Following actions are not defined in the repository: $(($MissingActions | sort -unique)-join', '). Use -IgnoreMissing to force execution."
		New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -ComputerName $target -Arguments $Arguments

		Write-Verbose "$Function Leaving $Function"
		return
	  }
	}

	# read targets
	$targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

	# apply each rule for each target
	foreach ($target in $targets)
	{
		Write-Progress -Activity "Running $Function" -Status "Check connection to $target..."

		if (!(Test-Connection $target -Quiet -Count 1))
		{
			$Status="fail"
			$Reason="Offline"
			$ret += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -ComputerName $target -Arguments $Arguments
		}
		else
		{
			Write-Verbose "$Function Processing target $target"

			foreach ($Rule in $ParsedRule)
			{
				$RuleName = $Rule.name

				Write-Progress -Activity "Running $Function" -Status "Processing rule $($RuleName) on $target..."
				Write-Verbose "$Function Processing Rule: $RuleName"

				$Actions = $Rule.Action

				foreach ($Action in $Actions)
				{
					$ActionName = $Action.type
					$CustomAction = $Action.action
					$CustomMethod = $Action.method

					Write-Progress -Activity "Running $Function" -Status "Processing Category $ActionName from rule $RuleName on host $target..."

					$val = $null

					if ($Script:Repository.$ActionName)
					{
						if (!$CustomAction)
						{
							$CommandAction  = "$($Script:Repository.$ActionName.$("Action$($Script:Repository.$ActionName.DefaultAction)"))"
							Write-Verbose "Rule $RuleName - Action $ActionName - Using default action: $CommandAction"
						}
						else
						{
						  	$AvailableActions = $Script:Repository.$ActionName.Actions

							if ($AvailableActions -contains $CustomAction)
							{
								$CommandAction  = "$($Script:Repository.$ActionName.$("Action$CustomAction"))"
								Write-Verbose "Rule $RuleName - Action $ActionName - Using custom action: $CommandAction"
							}
							else
							{
								$CommandAction  = "$($Script:Repository.$ActionName.$("Action$($Script:Repository.$ActionName.DefaultAction)"))"
							    write-error "`"$CustomAction`" is not a valid action. Allowed actions: $(($AvailableActions)-join", "). Default action is used: $CommandAction"
								Write-Verbose "Rule $RuleName - Action $ActionName - Using default method: $CommandAction"
							}
						}

						if (!$CustomMethod)
						{
							$CommandMethod  = "$($Script:Repository.$ActionName.DefaultMethod)"
							Write-Verbose "Rule $RuleName - Action $ActionName - Using default method: $CommandMethod"
							
						}
						else
						{
						  	$AvailableMethods = $Script:Repository.$ActionName.Methods

						    if ($AvailableMethods -contains $CustomMethod)
							{
								$CommandMethod  = $CustomMethod
								Write-Verbose "Rule $RuleName - Action $ActionName - Using custom method: $CommandMethod"
							}
							else
							{
							    write-error "$CustomMethod is not a valid method. Allowed methods: $(($AvailableMethods)-join", "). Default method is used."
								$CommandMethod  = "$($Script:Repository.$ActionName.DefaultMethod)"
								Write-Verbose "Rule $RuleName - Action $ActionName - Using default method: $CommandMethod"
							}

						}

						Write-Progress -Activity "Running $Function" -Status "Processing action `"$CommandAction`" and from category `"$ActionName`" from rule `"$RuleName`" on host `"$target`"..."

						$Command = "`$val = "
						$Command += $CommandAction
						$DefaultParams = @{
							OnlineCheck =  $OnlineCheck
							ComputerName =  $target
						}
						$Command += " @DefaultParams"
						$Command += " -Method $CommandMethod"
						
						$Params = $Script:Repository.$ActionName.Parameter
						foreach ($Param in $Params.Keys)
						{
							# todo add posiblity to use switch parameters
							# => empty value could be used as switch parameters
							if (!$($Action.$Param))
							{
								write-error "No value for parameter $($params.$Param) for action $ActionName in rule $RuleName"
								# todo fix command if no value is available - abort?
								$Command = ""
							}
							else
							{
								$Command += " $($Params.$Param) `"$($Action.$Param)`""
							}
						}

						if ($PrintCommand)
						{
							write $Command
						}
						else
						{
							Invoke-Expression $Command
						}
					}
					
					$ret += $val
				} # foreach category within rule
			} # foreach rule

			$Status="pass"
			$Reason="Successfully invoked PowerSponse$(if ($PrintCommand) {" without executing the commands (PrintCommand)"})"
			$ret += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -ComputerName $target -Arguments $Arguments

		} # host available
	} # foreach target

	$ret
	Write-Verbose "$Function Leaving $Function"
} # Invoke-PowerSponse

function Get-PowerSponseRule()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[string]
		$RuleFile = $(throw "you have to provide a rule"),

		[validateset("xml","json")]
		[string]
		$method = ""
	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "$Function Entering $Function"

	if (!(Test-Path $RuleFile))
	{
		throw "$RuleFile not found"
	}
	
	if (!$method)
	{
	  # check extension of rule file and decide which method should be used
	  $fileExt = [System.IO.Path]::GetExtension("$RuleFile")
	  $method = $fileExt[1..$fileExt.Length]-join''
	  write-verbose "Using method $method based on file extension $fileExt"
	}
	else
	{
	  write-verbose "Using method $method supplied by parameter"
	}
	
	# removes duplicate entries which is normal in CORE rules
	# NOT USABLE
	if ($method -match "json")
	{
		$Rules = (get-content "$RuleFile" -raw) | ConvertFrom-Json
		$Rules = $Rules.PowerSponse.Rule
	}
	# more flexible than ConvertFrom-String
	# good for meta data etc.
	# BAD: ORDNER IS NOT MAINTAINED
	elseif ($method -match "xml")
	{
		try
		{
			$Rules = ([xml] (get-content $RuleFile)).PowerSponse.Rule
		}
		catch
		{
			throw "XML could not be parsed - check XML scheme and syntax"
		}
	}

	if (!$Rules)
	{
		write-error "Could not read PowerSponse rules - check XML scheme"
	}
	else
	{
		$Rules
	}

	foreach ($rule in $rules)
	{
		write-verbose "Rule $($Rule.Name)"
		write-verbose "------------------"
		write-verbose "Author:	$($Rule.author)"
		write-verbose "Date:	$($Rule.date)"
		write-verbose "Links:	$($Rule.links)"
		write-verbose "------------------"
		foreach ($act in $Rule.action)
		{
			Write-Verbose "$($act.type)"
		}
		Write-Verbose "------------------"
	}

	Write-Verbose "$Function Leaving $Function"
} #Get-PowerSponseRule

Function New-CleanupPackage()
{
	[CmdletBinding(SupportsShouldProcess=$True)]
	param(
		[Parameter(Mandatory=$true)]
		[string]
		$RuleFile = $(throw "you have to provide a rule"),

		[string]
		$ComputerName = "localhost",

		[string] $OutputPath = $ModuleRoot,

		[string] $PackageName = "Cleanup-$([guid]::NewGuid().Guid).ps1",

		[switch]
		$IgnoreMissing

	)

	$Function = $MyInvocation.MyCommand
	Write-Verbose "$Function Entering $Function"

	Write-Progress -Activity "Running $Function" -Status "Build cleanup package..."

	if (!(Test-Path $OutputPath))
	{
		write-error "$OutputPath not found"
	}

	# path to cleanup file
	$FilePath = "$OutputPath\$PackageName"
	
	$ParsedRule = Get-PowerSponseRule -RuleFile $RuleFile
	
	# Todo Check custom local repository defintion (overwrite defaults)

	if (!$IgnoreMissing)
	{
	  foreach ($Rule in $ParsedRule)
	  {
		  $MissingActions = @()
		  $Actions = $Rule.Action

		  foreach ($Action in $Actions)
		  {
			  $ActionName = $Action.type

			  if (!$Script:Repository.$ActionName)
			  {
				  $Status="fail"
				  $MissingActions += $ActionName
				  Write-Verbose $ActionName
			  }
		  }
	  }

	  if ($MissingActions)
	  {
		$Reason="Following actions are not defined in the repository: $(($MissingActions | sort -unique)-join', '). Use -IgnoreMissing to force execution."
		New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -ComputerName $target -Arguments $Arguments

		Write-Verbose "$Function Leaving $Function"
		return
	  }
	}

	# read all functions and write them into the cleanup file
	$FunctionFiles = get-childitem -Filter *.ps1  -path $ModuleRoot\functions\ | ? { `
			$_.FullName -notmatch "\\test\\" -and `
			$_.FullName -notmatch "\\bin\\" -and `
			$_.FullName -notmatch "Template.ps1"`
		}
	$Functions = $FunctionFiles | get-content
	$Functions | Set-Content $FilePath
	
	# write commands for cleanup
	""  | Add-Content $FilePath
	"#####" | Add-Content $FilePath
	"## PowerSponse Cleanup Package for $ComputerName and rulefile $RuleFile" | Add-Content $FilePath
	"#####" | Add-Content $FilePath
	""  | Add-Content $FilePath
	"`$ModuleRoot = `$PSScriptRoot" | Add-Content $FilePath
	""  | Add-Content $FilePath
	"`$ret = @()" | Add-Content $FilePath
	""  | Add-Content $FilePath

	foreach ($Rule in $ParsedRule)
	{
		$RuleName = $Rule.name

		"## PowerSponse cleanup commands rule $RuleName" | Add-Content $FilePath

		$Actions = $Rule.Action

		foreach ($Action in $Actions)
		{
			$ActionName = $Action.type
			$CustomAction = $Action.action
			$CustomMethod = $Action.method

			if ($Script:Repository.$ActionName)
			{
				if (!$CustomAction)
				{
					$CommandAction  = "$($Script:Repository.$ActionName.$("Action$($Script:Repository.$ActionName.DefaultAction)"))"
					Write-Verbose "Rule $RuleName - Action $ActionName - Using default action: $CommandAction"
				}
				else
				{
					$AvailableActions = $Script:Repository.$ActionName.Actions

					if ($AvailableActions -contains $CustomAction)
					{
						$CommandAction  = "$($Script:Repository.$ActionName.$("Action$CustomAction"))"
						Write-Verbose "Rule $RuleName - Action $ActionName - Using custom action: $CommandAction"
					}
					else
					{
						$CommandAction  = "$($Script:Repository.$ActionName.$("Action$($Script:Repository.$ActionName.DefaultAction)"))"
						write-error "`"$CustomAction`" is not a valid action. Allowed actions: $(($AvailableActions)-join", "). Default action is used: $CommandAction"
						Write-Verbose "Rule $RuleName - Action $ActionName - Using default method: $CommandAction"
					}
				}

				if (!$CustomMethod)
				{
					$CommandMethod  = "$($Script:Repository.$ActionName.DefaultMethod)"
					Write-Verbose "Rule $RuleName - Action $ActionName - Using default method: $CommandMethod"
					
				}
				else
				{
					$AvailableMethods = $Script:Repository.$ActionName.Methods

					if ($AvailableMethods -contains $CustomMethod)
					{
						$CommandMethod  = $CustomMethod
						Write-Verbose "Rule $RuleName - Action $ActionName - Using custom method: $CommandMethod"
					}
					else
					{
						write-error "$CustomMethod is not a valid method. Allowed methods: $(($AvailableMethods)-join", "). Default method is used."
						$CommandMethod  = "$($Script:Repository.$ActionName.DefaultMethod)"
						Write-Verbose "Rule $RuleName - Action $ActionName - Using default method: $CommandMethod"
					}

				}

				Write-Progress -Activity "Running $Function" -Status "Processing action `"$CommandAction`" and from category `"$ActionName`" from rule `"$RuleName`" on host `"$ComputerName`"..."

				$Command = "`$ret += "
				$Command += $CommandAction
				$Command += " -OnlineCheck:`$False -ComputerName:$ComputerName"
				$Command += " -Method $CommandMethod"

				$Params = $Script:Repository.$ActionName.Parameter
				foreach ($Param in $Params.Keys)
				{
					# todo add posiblity to use switch parameters
					# => empty value could be used as switch parameters
					if (!$($Action.$Param))
					{
						write-error "No value for parameter $($params.$Param) for action $ActionName."
						# todo fix command if no value is available - abort?
						$Command = ""
					}
					else
					{
						$Command += " $($Params.$Param) `"$($Action.$Param)`""
					}
				}


				Write-Verbose $Command
				$Command | Add-Content $FilePath
			}
		} # foreach category within rule
		""  | Add-Content $FilePath
		"#####" | Add-Content $FilePath
	} # foreach rule

		""  | Add-Content $FilePath
	"`$ret" | Add-Content $FilePath
		""  | Add-Content $FilePath
	"#####" | Add-Content $FilePath

	Write-host "Wrote cleanup script to $FilePath"

	Write-Verbose "$Function Leaving $Function"
} # New-CleanupPackage

function Get-PowerSponseRepository()
{
	# Serialize and Deserialize data using BinaryFormatter
	$ms = New-Object System.IO.MemoryStream
	$bf = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
	$bf.Serialize($ms, $Script:Repository)
	$ms.Position = 0
	$dataDeep = $bf.Deserialize($ms)
	$ms.Close()
	return $dataDeep
}

function Set-PowerSponseRepository()
{
	param(
		[System.Collections.Hashtable] $NewRepository
	)
	if ($NewRepository)
	{
		$Script:Repository = $NewRepository
	}
	else
	{
		write-error "New repository is empty"
	}
}

Function Import-PowerSponseRepository()
{
	$Script:Repository = {}
	. "$ModuleRoot\Repository.ps1"
}

#region INITIALIZATION

# Module path for all functions
$ModuleRoot = $PSScriptRoot

# load repository
Import-PowerSponseRepository

# Load all functions
Get-ChildItem -Path "$ModuleRoot\functions\" -Exclude "Template.ps1" -Filter *.ps1 -Recurse | % { . $_.FullName}

#endregion

Export-ModuleMember @(
	'Invoke-PowerSponse',
	'New-CleanupPackage',
	'Get-PowerSponseRule',
	'Get-Process',
	'Start-Process',
	'Stop-Process',
	'Start-Service',
	'Stop-Service',
	'Enable-Service',
	'Disable-Service',
	'Get-ScheduledTask',
	'Enable-ScheduledTask',
	'Disable-ScheduledTask',
	'Stop-Computer',
	'Restart-Computer',
	'Get-NetworkInterface',
	'Enable-NetworkInterface',
	'Disable-NetworkInterface',
	'Get-Autoruns',
	'Enable-RemoteRegistry',
	'Disable-RemoteRegistry',
	'Get-PowerSponseRepository',
	'Set-PowerSponseRepository',
	'Import-PowerSponseRepository',
	'Get-FileHandle',
    'Invoke-PsExec'
)

#endregion
