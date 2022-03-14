# CHANGELOG
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

Update March 2022: Install PowerSponse from PowerShell Gallery was only 
supported until March 2022. Afterwards, only manual install through 
GitHub is provided. 

## [Unreleased](https://github.com/swisscom/PowerSponse/compare/v0.3.0...master)

<!--
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
-->

## [v0.3.0](https://github.com/swisscom/PowerSponse/compare/v0.2.2...v0.3.0) - 2019-05-15

Add file hash in return object for `find-file` command and fix an issue with
`-WhatIf` parameter in `Invoke-PowerSponse`.

### Added
* Return file hash in `find-file` command ([#9](https://github.com/swisscom/PowerSponse/issues/9)).
### Fixed
* Fix issue with `-WhatIf` parameter when called from `Invoke-PowerSponse`.

## [v0.2.2](https://github.com/swisscom/PowerSponse/compare/v0.2.1...v0.2.2) - 2019-04-04

Fix credential handling in new file and directory commands when using
`-Credential` parameter. Furthermore, improve PowerShell help.

## [v0.2.1](https://github.com/swisscom/PowerSponse/compare/v0.2.0...v0.2.1) - 2019-04-02

Update `Get-ScheduledTask` documentation and fix missing bin folder in PowerShell Gallery.

## [v0.2.0](https://github.com/swisscom/PowerSponse/compare/v0.1.0...v0.2.0) - 2019-04-02

Finally **add WinRM implementation for finding or removing files and
directories based on simple wildcards like * or the use of regex which is
matched against the whole path**. Beside the WinRM implementations for file
system handling, the get and stop process functions got their WinRM
implementation as well. The repository file was changed to reflect those changes.
The main functions using CORE rules (`Invoke-PowerSponse` and
`New-CleanupPackage`) were updated too to allow the use of optional parameters
in rules.

Furthermore, a generic command `Invoke-PsExec` was added for a more convenient
way to invoke PsExec.

### Added
* Add `Invoke-PsExec` for easier usage of PsExec and remote command execution.
    The function returns both the PowerSponse objects (fail/pass, timestamp,
    ...) and the program output (exit code, stdout, stderr).
* Add WinRM implementation for `Get-Process`. The use of regex is possible.
* Add WinRM implementation for `Stop-Process`. The use of regex is possible.
* Add WinRM implementation for `Find-File`. The use of wildcards like * and
  regex is possible.
* Add WinRM implementation for `Find-Directory`. The use of wildcards like * and
  regex is possible.
* Add WinRM implementation for `Remove-File`. The use of wildcards like * and
  regex is possible.
* Add WinRM implementation for `Remove-Directory`. The use of wildcards like * and
  regex is possible.
* Add example emotet CORE rule.
* Add examples to `Get-PowerSponseRule` help 
### Changed
* Use `Invoke-PsExec` inside of `Get-Autoruns`. Therefore, the whole handling
    of RemoteRegistry is not needed in `Get-Autoruns` and all code is inside
    `Invoke-PsExec`.
* Add parameter `FilenamePostfix` to specify postfix for filename in output of
    `Get-Autoruns`.
* The main functions using CORE rules (`Invoke-PowerSponse` and
  `New-CleanupPackage`) were updated to allow the use of optional parameters in
  rules.
* Update Repository to reflect all those changes above.
### Fixed
* Fix variable in process handling due to the reserved $Pid variable in PS.
### Removed
* Remove WMI file commands because they never worked (well).

## [v0.1.0](https://github.com/swisscom/PowerSponse/tree/v0.1.0) - 2018-08-02

:tada: Initial public release. :tada:

This release includes basic **commands for contain malicious scheduled tasks,
services, processes and some other host commands (e.g. disable network
interface)**. Allow using the commands against remote host or without a given
hostname run the command against localhost. Furthermore, a **rule engine was
implemented to allow using CoRe (COntainment and REmediation) rules** and use
them for containment. A **plugin architecture** was used to allow an easy way
to add new functions.
	
### Added
* Setup for building markdown and external help with **platyPS**.
* Add plugin functionality for functions. All functions are in the subfolder functions/*.
* Introduce **plugin architecture** to `Invoke-PowerSponse`. Add
		the available functions for Invoke-PowerSponse to the repository which is
		then used when processing CORE rules.
* Initial version of **CoRe rule** engine and syntax [CORE](CORE-RULES.md). **XML or JSON
    can be used for defining a CoRe rule**. By default XML is used to parse a
    rule, when using JSON change the method using `-Method json`.
    If no method is given when calling the `Invoke-PowerSponse` the file
    extension is used to decide whether to use the XML or JSON parser. Use
    OpenIOC terms for CoRe rule actions.
* Add functionality to create a **cleanup package for offline deployment**
  for deployment without direct network connection (`New-CleanupPackage`). The
  function packs all available functions into one file and adds the cleanup
  commands at the end of the script. This script can be executed locally on
  the target without a remote connection.
* Add following functions
    * Add `Invoke-PowerSponse` as the main function for using CoRe rules
      and to build offline cleanup packages.
    * Add function to parse CoRe rules (`Get-PowerSponseRule`) and display the
      rule.
    * Service functions (`Edit-Service`, `Start-Service`, `Stop-Service`,
	  `Disable-Service`, `Enable-Service`, `Get-Service`)
    * Enable and disable RemoteRegistry (`Enable-RemoteRegistry`, `Disable-RemoteRegistry`)
    * Get, start and kill processes (`Get-Process`, `Start-process`, `Stop-Process`)
    * Get ,enable and disable scheduled tasks (`Get-ScheduledTask`, `Enable-ScheduledTask`,
	  `Disable-ScheduledTask`)
    * Get, enable and disable network adpaters (`Get-NetworkInterface`, `Edit-NetworkInterface`, 
    `Enable-NetworkInterface`, `Disable-NetworkInterface`)
    * Find files based on regex (`Find-File`)
    * Get PowerSponse repository (see [Repository Configuration](Repository.ps1)
	  for functions which are supported by `Invoke-PowerSponse`). Use 
      `Get-PowerSponseRepository` and to change the current repository use
      `Set-PowerSponseRepository`.
	* Reading certificates using WinRM based on regex (`Get-Certificate`)
	* Reading the open file handles by process name or pid (`Get-FileHandle`)
    * Restart and shutdown hosts (`Restart-Computer`,
      `Stop-Computer`) using WMI.
    * Add `Get-Autoruns` for collecting autorunsc output into a csv file. The
		command can be used with a target list or with multiple computer names.
* Add regex functionality to different functions, e.g. to search scheduled
  tasks or services based on a regex expressions.
* Internal support Function
    * Function for handling target lists (`Get-Target`). `Get-Target` can
      handle `-ComputerName` and/or `-ComputerList` for the definition of
      target hosts.
    * Function for creating standard PowerSponse response objects
      (`New-PowerSponseObject`).
* Use method **WMI by default** (use "-method" to change that if function allows).
* Check for missing action types to `Invoke-PowerSponse` and to
  `New-CleanupPackage`. If an action type is used within a CoRe rule which
  is not available in the repository then stop execution.
* Add markdown help files and PowerShell help
* Add download script for required binaries when using PsExec etc. See README
  and PowerShell script in the \bin folder.
* Initial **Pester** tests.
