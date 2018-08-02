<#

.SYNOPSIS
	The scripts downloads the needed binaries for PowerSponse into the current
	directory. The script moves the current files within the \bin folder to _old.
	The binary urls must be supplied with a text file called 'binary-urls.txt'.
  

.DESCRIPTION
	PowerSponse depends on different external tools. This script downloads them
	into the current directory (usually the bin folder). If a .zip is downloaded
	it will unzip the files accordingly.

.PARAMETER ProxyUrl
  Defines the proxy to use otherwise a direct connection is used

.EXAMPLE

  powershell -ep bypass "<path-to-module>\bin\DownloadBinariesToCurrentDir.ps1"

  Downloads the files from binary-urls.txt into the root folder of the script.

.EXAMPLE
  .\DownloadBinariesToCurrentDir.ps1 -ProxyUrl "http://proxy.awesome-company.com:1234"

  Downloads the binaries with the specified proxy into current directory
  and unzips the ZIP file if needed.

.EXAMPLE
  .\DownloadBinariesToCurrentDir.ps1 -WhatIf

  This is the standard PowerShell "WhatIf" parameter. Shows the actions
  performed by the script.
#>


[CmdletBinding(SupportsShouldProcess=$True)]
param
(
	[string]$ProxyUrl = "",
	[string]$UrlFile = "binary-urls.txt"
)

if ($(Test-Path "$PSScriptRoot\$UrlFile") -ne $true)
{
	Write-Error "Textfile with URLs missing. The textfile must have the name `"binary-urls.txt`". Otherwise, please specifiy the parameter 'UrlFile'."
	Exit
}
$urls = gc "$PSScriptRoot\$UrlFile"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip()
{
	param(
		[string]$zipfile,
		[string]$outpath
	)
	[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

if (gci -Path "$PSScriptRoot\*" -Include *.exe,*.zip -File)
{
	if ((test-path "$PSScriptRoot\_old") -and (gci "$PSScriptRoot\_old\"))
	{
		Write-Error "An `"_old`" folder with files already exists, can't move current binaries to it. Please remove the folder or rename it before running the script."
		Exit
	}
	New-Item -ItemType "directory" -Path $PSScriptRoot -Name "_old" -ErrorAction SilentlyContinue
	gci -Path "$PSScriptRoot\*" -Include *.exe,*.zip -File | Move-Item -Destination "$PSScriptRoot\_old\" -Force
}

if ($ProxyUrl -ne "")
{
	foreach ($url in $urls)
	{
		if ($pscmdlet.ShouldProcess("$url", "Download $url to $PSScriptRoot\$([System.IO.Path]::GetFileName($url))"))
		{
			try
			{
				Invoke-WebRequest -Proxy $ProxyUrl -ProxyUseDefaultCredentials $url -OutFile "$PSScriptRoot\$([System.IO.Path]::GetFileName($url))"
			}
			catch
			{
				Write-error "Problem with Invoke-WebRequest. Pleaes specifiy the proxy if needed and check your Internet connection."
				Exit
			}
		}
	}
}
else
{
	foreach ($url in $urls)
	{
		if ($pscmdlet.ShouldProcess("$PSScriptRoot\$([System.IO.Path]::GetFileName($url))", "Download $url"))
		{
			try
			{
				Invoke-WebRequest $url -OutFile "$PSScriptRoot\$([System.IO.Path]::GetFileName($url))"
			}
			catch
			{
				Write-error "Problem with Invoke-WebRequest. Pleaes specifiy the proxy if needed and check your Internet connection."
				Exit
			}
		}
	}
}

if ($pscmdlet.ShouldProcess("$PSScriptRoot", "Unzip all .zip files within '$PSScriptRoot\'")){
	if ($psversiontable.psversion.major -gt 4)
	{
		gci $PSScriptRoot\*.zip | % { Expand-Archive $_ -DestinationPath "$PSScriptRoot\" -Force }
	}
	else
	{
		gci $PSScriptRoot\*.zip | % { Unzip $_ "$PSScriptRoot\" }
	}
}
