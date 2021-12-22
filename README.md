![PowerSponse - PowerShell module for containment and remediation](media/powersponse.png)

# PowerSponse - PowerShell Module for Containment and Remediation

PowerSponse is a PowerShell module for targeted containment and remediation
during incident response.

Please see [Command Documentation](docs/PowerSponse.md),
[Wiki](https://github.com/swisscom/PowerSponse/wiki) and
[CHANGELOG](CHANGELOG.md).

***
<!-- vim-markdown-toc GFM -->

* [What is PowerSponse?](#what-is-powersponse)
* [Example](#example)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
    * [Authentication](#authentication)
    * [Import](#import)
    * [Cmdlets](#cmdlets)
    * [Help](#help)
* [Contributing](#contributing)
* [Inspiration](#inspiration)
* [References](#references)

<!-- vim-markdown-toc -->
***

## What is PowerSponse?

PowerSponse is a PowerShell module for targeted containment and remediation.

The following features are implemented in PowerSponse:
* Commands for containment and remediation which can be easily extended with
  the used plugin system.
* Handling of **literal or regular expressions** for searching or killing processes, 
  files and directories, searching for or deactivating scheduled tasks or services. 
* **Implementation of a rule engine** (**[CoRe
  rules](https://github.com/swisscom/PowerSponse/wiki/CoRe-rules)** which can be 
  used by `Invoke-PowerSponse` or `New-CleanupPackage` to reuse predefined
  actions, e.g. a CoRe rule per malware family). This should be the 
  [YARA](https://virustotal.github.io/yara/) or [SIGMA](https://github.com/Neo23x0/sigma) 
  equivalent but for containment.
* Use a CoRe rule for **specific cleanup against one or more remote** hosts using
    `Invoke-PowerSponse` or use `New-CleanupPackage` to **build a cleanup
    package** and deploy it to a remote host which is not reachable via network.

PowerSponse can be used in the **containment and remediation phase (deny, degrade and disrupt)** 
of an incident. Of course, the containment part contradicts with the forensic soundness, which
means that the source evidence (infected machine) is not altered in any
way. The question is always: Would you like to limit the damage during an attack
and control the communication flow to the attacker's servers or would you
like to collect more information from the attacker by just passive monitoring?

Different methods are used to connect and run the commands on remote hosts:
WMI, WinRM, PsExec, Windows' system tools.

Every action outputs the same PowerSponse object format for easy post processing: 
which command was run, target hostname, timestamp and status of the command.

The following use cases were in mind when implementing PowerSponse:
* Cleanup ***single artifact*** on ***one specific host***: Run single command
	directly against that host.
* Cleanup ***single artifact*** on ***multiple hosts***: Run single command
    against multiple hosts. Provide the list of computers with the 
    `-ComputerName host1,host2,...` or the `-ComputerList host.txt` parameter.
* Cleanup ***multiple artifacts*** on ***one specific or multiple host***: Run multiple commands
	against one or multiple host manually or use a PowerShell script with 
	all the needed PowerSponse cmdlets and concatenate the output for easy
	post processing. An other way would be to use `Invoke-PowerSponse` or 
	`New-CleanupPackage` with a 
	[CoRe rule](https://github.com/swisscom/PowerSponse/wiki/CoRe-rules).

## Example

Dridex (yeah, old stuff, the example is from 2016) creates some files, injects itself into
explorer and adds a scheduled task. Taken from [Detecting and removing
Dridex](http://lpine.org/2016/06/detecting-removing-dridex/), the manual steps
for containment are as follows:

> 1. Kill explorer.exe process using taskkill /f /im explorer.exe
> 2. Remove all tmp files from C:\users\username\data\locallow, del
> 	%userprofile%\appdata\locallow\*.tmp. There could be more than one user on
> 	a computer and you’d better traverse through all user profile folders to check
> 	for Dridex files.
> 3. Remove Dridex task using schtasks /delete /tn “User_Feed_Synchronization-{Dridex-Random-Hex-GUID}” /f
> 4. Reboot the PC.

With PowerSponse you could use these cmdlets directly (`@()` is used to
concatenate the output of all the commands).

``` powershell
PS> $ret = @()
PS> $ret += Stop-Process -ComputerName comp1 -Name "explorer"
PS> $ret += Remove-File -ComputerName comp1 -Path "C:\users\*\appdata\locallow\*.tmp
PS> $ret += Disable-ScheduledTask -ComputerName comp1 -TaskName "User_F.*_S.*-\{.{8}-(.{4}-){3}.{12}\}"
PS> $ret += Restart-Computer -ComputerName comp1
PS> $ret | select time, action, computername, status, reason

Time                Action                  ComputerName  Status Reason
----                ------                  ------------  ------ ------
08.01.2017 16:41:36 Stop-Process            comp1         pass   Stopped
08.01.2017 16:41:47 Remove-File             comp1         pass   Removed
08.01.2017 16:41:52 Disable-ScheduledTask   comp1         pass   Disabled
08.01.2017 16:41:54 Restart-Computer        comp1         pass   Rebooted
```

Or create a corresponding
[CoRe rule](https://github.com/swisscom/PowerSponse/wiki/CoRe-rules) and use
the rule in combination with `Invoke-PowerSponse` or `New-CleanupPackage`.

``` json
{
    "PowerSponse": [
        {
            "id" : "12341234-1234-1234-1234-123412341234",
            "name" : "Dridex June 2016",
            "date" : "2016-06-01",
            "author" : "Mr. Evil",
            "description" : "Dridex cleanup rule.",
            "action" : [
                {
                    "type" : "ProcessItem",
                    "name" : "explorer.exe"
                },
                {
                    "type" : "FileItem",
                    "Path" : "C:\\users\\*\\appdata\\locallow\\*.tmp"
                },
                {
                    "type" : "TaskItem",
                    "searchstring" : "User_F.*_S.*-\\{.{8}-(.{4}-){3}.{12}\\}"
                },
                {
                    "type" : "ComputerItem",
                    "action" : "reboot"
                }
            ]
        }
    ]
}
```

``` powershell
PS> Invoke-PowerSponse -ComputerName comp1 -Rule dridex-201606.json
```

``` powershell
PS> New-CleanupPackage -Rule dridex-201606.json
```

Instead of running the commands directly against the target computers, you can use
`New-CleanupPackage` which concatenates all scripts and commands into a new 
PowerShell script and therefore allows an offline deployment to the 
target host without having a direct network connection.

## Requirements

To run PowerSponse commands via network you need remote administrator rights
and need some ports open on the target machine, depending which
method (WinRM, WMI, PsExec, ...) the remote management protocols use 135 TCP, 139 TCP, 445
TCP, 5985 TCP, 5986 TCP. Alternatively, run the commands and PowerSponse
scripts directly on the target (localhost) by importing the module on the
target machine or by using the `New-CleanupPackage` in combination with a 
CoRe rule.

## Installation

* **Install PowerSponse from [PowerShell Gallery](https://www.powershellgallery.com/packages/PowerSponse/)**. [PowerShellGet](https://github.com/powerShell/powershellget) is required which is installed in PowerShell Core and since Windows PowerShell v5 by default. Only released versions are available there, see [CHANGELOG](CHANGELOG.md).

    ``` powershell
    # Inspect
    Save-Module -Name PowerSponse -Path <path> 

    # Install
    Install-Module -Name PowerSponse -Scope CurrentUser -AllowClobber

    # Update
    Update-Module -Name PowerSponse
    ```

   If you get an error, try using the following command to set PowerShell Gallery as one of your repositories:

   ``` powershell
   Register-PSRepository -Default
   ```

* **Install PowerSponse from Github**

    * Clone or download the repo into your module path folder, usually
      _~\Documents\WindowsPowerShell\modules_ on Windows (see _$env:PSModulePath_).
    * Clone or download the files to any other folder (could also be a share).
    * The location changes how the module is imported. See import below.
    * **Make sure to unblock the files** - either using the command below or by opening 
      the properties page of all the the .psd1 and .psm1 files and checking 
      "Unblock" at the bottom.

      ``` powershell
      gci <module path> -Recurse -Include *.ps1,*.psm1,*.psd1 | Unblock-File
      ```

* **OPTIONALLY** Download the needed binaries (only if you need them for the used commands)
  or put them manually in the bin folder. See README and binary-urls.txt
  inside the \bin folder. By default only some Sysinternal tools are
  downloaded (e.g. pskill, psexec, ...).

  ```
  cd <path-to-module>\bin
  powershell -ep bypass .\DownloadBinariesToCurrentDir.ps1
  ```

## Usage

Use `command -<tab>` to tab between the available parameters or use 
`command -<ctrl+space>` to display a list of all paremeters. 

**Disclaimer:** _The command interface is inconsistent, that means that some
commands can have a `-Credential` parameter (WMI and WinRM can handle
credential objects) and other commands which rely on external tools do not
(passwords in logs are bad, very bad). Some commands have a WMI
implementation, others do only have an implementation using an external tool.
Read through the docs, try the commands out and make a pull request for
missing functionality. There are a lot of missing commands...That said, enjoy
mitigating the evil._


### Authentication

* Start a shell in escalated mode with your remote admin account
  (shift-right-click and use "run as different user")
* Start a shell with your user and store your credentials in a credential
  variable and pass it to the commands with `-Credential`

    ```powershell
    $creds = Microsoft.PowerShell.Security\get-credential
    ```

### Import

If PowerSponse was saved inside the module path run the following command:

``` powershell
Import-Module PowerSponse -force
```

If PowerSponse was saved outside the module path run the command:

``` powershell
Import-Module <path to module>\PowerSponse.psd1 -force
```

### Cmdlets

Please see [docs](docs/PowerSponse.md) and the wiki for the list of all available commands.

Use the common parameters like _-WhatIf_ or _-Verbose_ for troubleshooting and to
see what the commands would do. _WhatIf_ is implemented for every function which
makes any changes.

List available PowerSponse commands.

``` powershell
get-command -Module PowerSponse
```

List all PowerSponse commands for tasks

``` powershell
get-command -Module PowerSponse | sls task
```

### Help

Use `help <command>` to get the help for a command.

```powershell
PS> help Get-ScheduledTask

NAME
    Get-ScheduledTask

OVERVIEW
    Find scheduled tasks based on regex.

SYNTAX
    Get-ScheduledTask [-BinPath <String>] [-ComputerList <String>] [-ComputerName <String[]>] [-Confirm] [-Credential <PSCredential>] [-PrintXML] [-Session <PSSession>[]>] [-WhatIf] [-NoRemoteRegistry] [-OnlyTaskName] [-SearchString <String>] [-Method <String>] [-OnlineCheck] [<CommonParameters>]

DESCRIPTION
    Find scheduled tasks based on a literal or regex.
...
```

Use `help <command> -Examples` to get examples for a command.

```powershell
PS> help Get-ScheduledTask -Examples

NAME
    Get-ScheduledTask

OVERVIEW
    Find scheduled tasks based on literal or regex.

    Example 1

    PS> Get-ScheduledTask -SearchString ".*-S-\d{1}-\d{1}" -NoRemoteRegistry -OnlyTaskName


    Time         : 06.01.2017 10:31:29
    Action       : Get-ScheduledTask
    ComputerName : localhost
    Arguments    : TaskName: .*-S-\d{1}-\d{1}
    Status       : pass
    Reason       : \G2MUpdateTask-S-1-5-21-111111111-2222222222-333333333-444444 ; \G2MUploadTask-S-1-5-21-111111111-2222222222-333333333-444444

...
```
Some commands have the same name as the native cmdlets (e.g. `Stop-Service`). For these cmdlets you
need to prefix the cmdlet name with the specific module when using help: `help powersponse\stop-service`.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for general guidelines.

## Inspiration
* [PowerForensics](https://github.com/Invoke-IR/PowerForensics)
* [Kansa](https://github.com/davehull/Kansa/)
* [Invoke-LiveResponse](https://github.com/davidhowell-tx/Invoke-LiveResponse)
* [Empire](https://github.com/adaptivethreat/Empire)
* [PowerSploit](https://github.com/PowerShellMafia/PowerSploit/)
* [AutoRuns PowerShell Module](https://github.com/p0w3rsh3ll/AutoRuns)

## References
* [PowerForensics and Remote Machines ](https://davidhowelltx.blogspot.ch/2016/04/powerforensics-and-remote-machines.html)
* [Invoke-IR](http://www.invoke-ir.com/)
* [Invoke-Command / PowerForensics PowerShell Remoting Usage](https://github.com/Invoke-IR/PowerForensics/issues/143)
* [PowerShell AutoRuns](https://github.com/p0w3rsh3ll/AutoRuns)
* [CimSweep](https://github.com/PowerShellMafia/CimSweep)
* [p0wnedShell](https://github.com/Cn33liz/p0wnedShell)
* [BloodHound](https://github.com/adaptivethreat/BloodHound)
* [PowerShell Remoting and Incident Response](https://www.linkedin.com/pulse/powershell-remoting-incident-response-matthew-green)
