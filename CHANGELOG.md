# CHANGELOG
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased](https://github.com/swisscom/PowerSponse/compare/v0.1.0...master)
### Added
* Add `Invoke-PsExec` for easier usage of PsExec and remote command execution.
    The function returns both the PowerSponse objects (fail/pass, timestamp,
    ...) and the program output (exit code, stdout, stderr).
* Add WinRM implementation for `Get-Process`
### Changed
* Use `Invoke-PsExec` inside of `Get-Autoruns`. Therefore, the whole handling
    of RemoteRegistry is not needed in `Get-Autoruns` and all code is inside
    `Invoke-PsExec`.
* Add parameter `FilenamePostfix` to specify postfix for filename in output of
    `Get-Autoruns`.
<!--
### Fixed
### Security
### Deprecated
### Removed
-->

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
