#
# Module manifest for module 'PowerSponse'
#
# Generated by: Swisscom (Schweiz) AG
#
# Generated on: 04.12.2016
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PowerSponse.psm1'

# Version number of this module.
ModuleVersion = '0.2.1'

# ID used to uniquely identify this module
GUID = 'ca85e27c-3d41-49a1-9315-fb44966836b7'

# Author of this module
Author = 'Swisscom (Schweiz) AG'

# Company or vendor of this module
CompanyName = 'Swisscom (Schweiz) AG'

# Copyright statement for this module
Copyright = '(c) 2019 Swisscom (Schweiz) AG'

# Description of the functionality provided by this module
Description = 'The module allows a fast and easy way to contain and remediate a threat on a remote host.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'None'

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = @(
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
    'Invoke-PsExec',
    'Find-File',
    'Find-Directory',
    'Get-Certificate'
    'Remove-File',
    'Remove-Directory'
	)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
	'PowerSponse.psd1',
	'PowerSponse.psm1',
	'en-us\PowerSponse-help.xml'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('IncidentResponse','Containment','Remediation','ActiveResponse')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/swisscom/PowerSponse/LICENSE.md'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/swisscom/PowerSponse'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
