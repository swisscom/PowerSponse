# returns a tuple (PowerSponse object and 2nd the execution output)
Function Invoke-PsExec()
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    param
    (
        [string[]] $ComputerName,
        [string] $Program,
        [string] $CommandLine,
        [switch] $AsSystem = $false,
        [switch] $CopyProgramToRemoteSystem = $false,
        [switch] $ForceCopyProgramToRemoteSystem = $false
    )

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

    $returnobject = @()
    $RemoteRegistryStarted = $false
    $WhatIfPassed = $false
    $Status = ""
    $Reason = ""
    $ReturnValue = $null

    Write-Verbose "Using PsExec for starting '$Program' on '$ComputerName'."

    $Arguments = "Program: $Program, CommandLine: $CommandLine, AsSystem: $AsSystem, CopyFile: $CopyProgramToRemoteSystem, ForceCopy: $ForceCopyProgramToRemoteSystem"

    $ComputerName = Get-Target -ComputerName:$(if ($ComputerName){$ComputerName})

    if ($PSBoundParameters.ContainsKey('whatif') -and $PSBoundParameters['whatif'])
    {
        $WhatIfPassed = $true
    }
    Write-Verbose "whatif: $WhatIfPassed"

    # Enable and start RemoteRegistry
    try
    {
        # Enable RemoteRegistry for psexec
        $params = @{
            'method' = "external";
            'ComputerName' = $ComputerName;
            'WhatIf' = $WhatIfPassed;
            'OnlineCheck' = $false
        }
        $err = Enable-RemoteRegistry @params
        $returnobject += $err
        $params = @{
            'ComputerName' = $ComputerName;
            'method' = "external";
            'WhatIf' = $WhatIfPassed;
            'Name' = "RemoteRegistry";
            'OnlineCheck' = $false
        }
        $srr = Start-Service @params
        $returnobject += $srr
        $RemoteRegistryStarted = ($srr.status -match "pass")
    }
    catch
    {
        $Status = "fail"
        $Reason = "Error while enabling RemoteRegistry"
        $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason
    }

    if ($pscmdlet.ShouldProcess($ComputerName, "Execute $Program $CommandLine"))
    {
        if ($RemoteRegistryStarted)
        {
            Write-Progress -Activity "Running $Function" -Status "Run '$Program $CommandLine' on $ComputerName..."

            $CommandLinePsExec  = "-accepteula -nobanner "
            $CommandLinePsExec += "\\$ComputerName "
            if ($AsSystem) {
                $CommandLinePsExec += "-s "
            }
            if ($CopyProgramToRemoteSystem)
            {
                $CommandLinePsExec += "-c "
            }
            if ($ForceCopyProgramToRemoteSystem)
            {
                $CommandLinePsExec += "-f "
            }
            $CommandLinePsExec += "`"$Program`" $CommandLine"

            Write-Verbose "Using CommandLine for PsExec: $CommandLinePsExec"

            $params = @{
               'Binary' = "PsExec.exe";
               'CommandLine' = $CommandLinePsExec
            }

            $ReturnValue = (Start-Process @params)

            if ($ReturnValue.exitcode -eq 0)
            {
                $Status = "pass"
                $Reason = "See stdout/stderr in return value."
            }
            else
            {
                $Status = "fail"
                $Reason = "Error running '$Program $CommandLine' on $ComputerName. Wrong arguments or could be due to permissions. See stdout/stderr from return value."
            }
        }
        else
        {
            $Status = "fail"
            $Reason = "RemoteRegistry could not be started."
        }
    } #no whatif given
    else
    {
        $Status = "pass"
        $Reason = "Not executed - started with -WhatIf"
    } #whatif used

    # Stop and Disable RemoteRegistry
    if ($RemoteRegistryStarted -or $WhatIfPassed)
    {
        try
        {
            Write-Verbose "Cleanup RemoteRegistry on $ComputerName"
            $srr = Stop-Service -ComputerName $ComputerName -method external -Name "RemoteRegistry" -WhatIf:$WhatIfPassed -OnlineCheck:$false
            $returnobject += $srr
            $drr = Disable-RemoteRegistry -method external -ComputerName $ComputerName -WhatIf:$WhatIfPassed -OnlineCheck:$false
            $returnobject += $drr
        }
        catch
        {
            $Status = "fail"
            $Reason = "Error while disabling RemoteRegistry"
        }
    }

    $returnobject += New-PowerSponseObject -Function $Function -ComputerName $ComputerName -Arguments $Arguments -Status $Status -Reason $Reason

    # returnobject with all powersponse objects and return value from psexec call
    $returnobject,$ReturnValue

    Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}

Function Get-Process()
{
    [CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='ByName')]
    param
    (
        [string[]] $ComputerName,

        [string] $ComputerList,

        [ValidateSet("WMI", "External", "WinRM")]
        [string] $Method = "WinRM",

        [string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

        [System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

        [System.Management.Automation.PSCredential] $Credential=$Null,

        [Parameter(ParameterSetName='ByName')]
        [string] $Name,

        [Parameter(ParameterSetName='ByPid')]
        [int] $Pid,

        [ValidateSet("OnlyPid", "OnlyName", "All")]
        [string] $OutputFormat = "all"
    )

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

    $returnobject = @()
    $res = ""

    $Arguments = $(if ($Name) { "Name $($Name)" } else { "Pid: $($Pid)" } )

    Write-Progress -Activity "Running $Function" -Status "Initializing..."

    if (!$Name -and !$Pid)
    {
        $Reason = "no process name or process id, please use -Name or -Pid"
        $Status = "fail"
        $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
    }
    elseif ($Name -and $Pid)
    {
        $Status = "fail"
        $Reason = "both process name or process id given"
        $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
    }
    else
    {
        $targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

        foreach ($target in $targets)
        {
            Write-Progress -Activity "Running $Function" -Status "Processing $target..."

            if ($pscmdlet.ShouldProcess($target, "Get process with method $($Method)"))
            {
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
                        Write-Verbose "Using WMI"

                        if (($target -eq "localhost") -and $Credential)
                        {
                            $Status = "fail"
                            $Reason = "localhost and WMI and credential not working"
                            $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
                            Continue
                        }
                        try
                        {
                            if ($Name)
                            {
                                $res = Get-WmiObject Win32_Process -ComputerName $target -Credential $Credential -ErrorAction Stop | ? {$_.name -match $Name -or $_.ExecutablePath -match $Name}
                            }
                            else
                            {
                                $res = Get-WmiObject Win32_Process -ComputerName $target -Credential $Credential -ErrorAction stop | ? {$_.Processid -eq $Pid}
                            }

                            if (!$res)
                            {
                                $Status = "fail"
                                $Reason = "no process found"
                            }
                            # not used currently to distinguish between one or multiple processes
                            #elseif ((($res | measure).count -gt 1 ))
                            #{
                            #    $Status = "fail"
                            #    $Reason = "multiple processes found"
                            #}
                            else
                            {
                                $Status = "pass"
                                $Reason = @()

                                foreach ($proc in $res)
                                {
                                    if ($OutputFormat -match "OnlyPid")
                                    {
                                     $Reason += "$($proc.ProcessId)"
                                    }
                                    elseif ($OutputFormat -match "OnlyName")
                                    {
                                        $Reason += "$($proc.ProcessName)"
                                    }
                                    else
                                    {
                                        $Reason += "$($proc.ProcessId) ; $($proc.ProcessName) ; $($proc.ExecutablePath)"
                                    }
                                }
                            }
                        } # wmi call Successfull
                        catch
                        {
                            $Status = "fail"
                            $Reason = "error while connecting to remote host"
                        }
                    }
                    elseif ($Method -match "winrm")
                    {
                        Write-Verbose "Using WinRM - Name: $Name, Id: $Pid"

                        try
                        {
                            $params = @{
                                'ea' = 'SilentlyContinue'
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

                            if ($Name)
                            {
                                $params += @{
                                    'ScriptBlock' = {Microsoft.PowerShell.Management\get-process -ea SilentlyContinue}
                                }
                                $res = invoke-command @params
                                $res = $res | ? { $_.ProcessName -match "$Name" -or $_.Path -match "$Name" } | select Id,ProcessName,Path
                            }
                            else
                            {
                                $params += @{
                                    'ScriptBlock' = {param($p1) Microsoft.PowerShell.Management\get-process -Id $p1 -ea SilentlyContinue}
                                    'ArgumentList' = $Pid
                                }

                                $res = invoke-command @params
                            }

                            if (!$res)
                            {
                                $Status = "fail"
                                $Reason = "no process found"
                            }
                            else
                            {
                                $Status = "pass"
                                $Reason = @()

                                foreach ($proc in $res)
                                {
                                    if ($OutputFormat -match "OnlyPid")
                                    {
                                     $Reason += "$($proc.Id)"
                                    }
                                    elseif ($OutputFormat -match "OnlyName")
                                    {
                                        $Reason += "$($proc.ProcessName)"
                                    }
                                    else
                                    {
                                        $Reason += "$($proc.Id) ; $($proc.ProcessName) ; $($proc.Path)"
                                    }
                                }
                            }
                        }
                        catch
                        {
                            $Status = "fail"
                            $Reason = "error while connecting to remote host"
                        }
                    }
                    elseif ($Method -match "external")
                    {
                        Write-Verbose "Using ExternalTools / Sysinternals"
                        Write-Verbose "BinPath: $BinPath"

                        if (!(Test-Path -Path "$BinPath\pslist.exe"))
                        {
                            $Status = "fail"
                            $Reason = "Binary pslist not found."
                        }
                        elseif (!(Test-Path -Path "$BinPath\psservice.exe"))
                        {
                            $Status = "fail"
                            $Reason = "Binary psservice not found."
                        }
                        else
                        {
                            # Enable RemoteRegistry for the target
                            try
                            {
                                $res = Enable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false
                                if ($res.status -match "pass")
                                {
                                    Start-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false
                                    $RemoteRegistryStarted = $true

                                    # todo pslist - check if multiple processes are running
                                    if ($Name)
                                    {
                                        $proc = Start-Process "pslist.exe" "-accepteula -nobanner \\$target $Name"
                                    }
                                    else
                                    {
                                        $proc = Start-Process "pslist.exe" "-accepteula -nobanner \\$target $Pid"
                                    }

                                    if ($proc.stdout | select-string "not" -quiet)
                                    {
                                        $Reason = "Process not found"
                                        $Status = "fail"
                                    }
                                    else
                                    {
                                        Write-Verbose "Process found"
                                        # todo if needed use
                                        # http://stackoverflow.com/questions/28287700/how-to-pipe-elapsed-time-or-other-output-from-pslist
                                        $MultipleProcesses = (($proc.stdout | measure -Line).Lines -gt 4)
                                        Write-Verbose "Process count: $($MultipleProcesses)"
                                        $Status = "pass"
                                        #$val = ($stdout.split("`n") | select -skip 2]
                                        $Reason = $proc.stdout
                                    }

                                    if ($proc.ExitCode -eq 0)
                                    {
                                        Write-Verbose "Successfully executed pslist on $target"
                                    }
                                    else
                                    {
                                        Write-Verbose  "Error while running pslist on $target"
                                    }

                                } # Enable-RemoteRegistry pass
                                else
                                {
                                    Write-Verbose "Error while enabling RemoteRegistry"
                                    $Reason = "Error while enabling RemoteRegistry"
                                    $Status = "fail"
                                }

                            } # no exception during enabling RemoteRegistry
                            catch
                            {
                                Write-Verbose "Error while enabling RemoteRegistry"
                                $Reason = "Error while enabling RemoteRegistry"
                                $Status = "fail"
                            }

                            try
                            {
                                # Cleanup
                                if ($RemoteRegistryStarted)
                                {
                                    Write-Verbose "Cleanup RemoteRegistry"
                                    Stop-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false
                                    Disable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false
                                }
                            }
                            catch
                            {
                                Write-Verbose "Error while disabling RemoteRegistry"
                                #fix when process found but disabling failed, info accordi
                                $Reason = "Error while disabling RemoteRegistry"
                                $Status = "fail"
                            }

                        } #Binaries available

                    } #UseExternal

                } #target online

                $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

            } #whatif

        } #each target

    } #parameters ok

    $returnobject
    Write-Verbose "Leaving $($MyInvocation.MyCommand)"
}

#
# Returns an object with ExitCode, stdout and stderr
#
# Used to start specified tool on remote host (e.g. md5deep, autoruns). Check
# Kansa and Invoke-LiveResponse first for this task.
Function Start-Process()
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    param
    (
        [string] $Binary,
        [string] $CommandLine = "",
        [string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin")
    )

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

    $return = @()

    $Arguments = "BinPath: $BinPath, Binary: $Binary, CommandLine: $CommandLine"
    Write-Verbose "Arguments: $Arguments"

    if (!$Binary)
    {
        $Status = "fail"
        $Reason = "Binary $Binary not given."
        write-output $Reason
        return
    }

    if (Test-Path "$BinPath\$Binary")
    {
        $Path = "$BinPath\$Binary"
    }
    else
    {
        $Path = $Binary
    }
    Write-Verbose $Path

    if ($pscmdlet.ShouldProcess("Execute Binary $Path with CommandLine $CommandLine"))
    {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "$Path"
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = "$CommandLine"
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo

        try
        {
            $p.Start() | Out-Null
            # todo fix timeout
            $p.WaitForExit(5000) | Out-Null

            $stdout = $p.StandardOutput.ReadToEnd()
            $stderr = $p.StandardError.ReadToEnd()

            $info = [ordered]@{
                ExitCode = $p.ExitCode
                stdout = $stdout
                stderr = $stderr
            }
        }
        catch
        {
            $info = [ordered]@{
                ExitCode = 1
                stdout = ""
                stderr = "Error starting $Binary, binary not found in path or bin folder"
            }
        }
        $ret = New-Object -TypeName PSObject -Property $info
        $return += $ret
    } #whatif
    $return
    Write-Verbose "Leaving $($MyInvocation.MyCommand)"
} # Start-Process

Function Stop-Process()
{
    [CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName='ByName')]
    param
    (
        [string[]] $ComputerName,

        [string] $ComputerList,

        [ValidateSet("WMI", "External", "WinRM")]
        [string] $Method = "WinRM",

        [string] $BinPath = $(Join-Path -Path $ModuleRoot -ChildPath "\bin"),

        [System.Management.Automation.Runspaces.PSSession[]] $Session=$Null,

        [System.Management.Automation.PSCredential] $Credential=$Null,

        [switch] $NoRemoteRegistry,

        [boolean] $OnlineCheck = $true,

        [Parameter(ParameterSetName='ByName')]
        [string] $Name,

        [Parameter(ParameterSetName='ByPid')]
        [int] $Pid,

        [switch] $StopAll

    )

    $Function = $MyInvocation.MyCommand
    Write-Verbose "Entering $Function"

    $returnobject = @()

    $Arguments = $(if ($Name) { "Name $($Name)" } else { "Pid: $($Pid)" } )
    $Arguments += ", StopAll: $StopAll"
    $Arguments += ", Onlinecheck: $OnlineCheck"
    Write-Verbose "Arguments: $Arguments"

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

    if (!$Name -and !$Pid)
    {
         $Status = "fail"
         $Reason = "no process name or process id"
         $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
    }
    elseif ($Name -and $Pid)
    {
         $Status = "fail"
         $Reason = "both process name or process id given"
         $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments
    }
    else
    {
        $targets = Get-Target -ComputerList:$(if ($ComputerList){$ComputerList}) -ComputerName:$(if ($ComputerName){$ComputerName})

        foreach ($target in $targets)
        {
            Write-Progress -Activity "Running $Function" -Status "Processing $target..."
            if ($pscmdlet.ShouldProcess($target, "Stop Process with method $($Method)"))
            {
                $IsLocalhost = ($target -match "localhost")
                if (!$IsLocalhost -and $OnlineCheck -and !(Test-Connection $target -Quiet -Count 2))
                {
                    Write-Verbose "$target is offline"
                    $Status = "fail"
                    $Reason = "offline"
                }
                else
                {
                    if ($Method -match "wmi")
                    {
                        Write-Verbose "Using WMI"

                        if (($target -eq "localhost") -and $Credential)
                        {
                            $Status = "fail"
                            $Reason = "localhost and WMI and credential not working"
                            $returnobject += New-PowerSponseObject -Function $function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target
                            Continue
                        }

                        if ($Name)
                        {
                            $res = Get-WmiObject Win32_Process -ComputerName $target -Credential $Credential | ? {$_.name -match $Name}
                        }
                        else
                        {
                            $res = Get-WmiObject Win32_Process -ComputerName $target -Credential $Credential | ? {$_.Processid -eq $Pid}
                        }

                        if (!$res)
                        {
                            $Status = "fail"
                            $Reason = "no process"
                        }
                        elseif ((($res | measure).count -gt 1 ) -and !$StopAll)
                        {
                            $Status = "fail"
                            $Reason = "multiple processes without -stopall"
                        }
                        else
                        {
                            $Reason = "Process(es) stopped: "
                            foreach ($proc in $res)
                            {
                                $rval = $proc.terminate().returnvalue
                                if ($rval -eq 0)
                                {
                                    $Status = "pass"
                                    $Reason += "PID:$($proc.ProcessId)($($proc.ProcessName)) "
                                }
                                elseif ($rval -eq 2)
                                {
                                    $Status = "fail"
                                    $Reason += "$($proc.ProcessPid)(Access denied)"
                                }
                                else
                                {
                                    $Status = "fail"
                                    $Reason += "$($proc.ProcessPid)(Unspecified error)"
                                }
                            }
                        }
                    }
                    elseif ($Method -match "winrm")
                    {
                        Write-Verbose "Using WinRM - Name: $Name, Id: $Pid"

                        if ($Name)
                        {
                            $ret = Get-Process -ComputerName $target -Method WinRM -Name $Name
                            $returnobject += $ret
                        }
                        else
                        {
                            $ret = Get-Process -ComputerName $target -Method WinRM -Pid $Pid
                            $returnobject += $ret
                        }

                        if ($ret -and ($ret.reason -match "no process found"))
                        {
                            $Status = "fail"
                            $Reason = "no process"
                            Continue
                        }
                        elseif ($ret -and ($ret.reason | measure).count -gt 1 -and !$StopAll)
                        {
                            $Status = "fail"
                            $Reason = "kill multiple processes without -stopall"
                        }
                        else
                        {
                            $processes = ( $ret.reason | foreach { ($_ -split ";")[0] } )

                            $params = @{
                                'ea' = 'SilentlyContinue'
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
                                'ScriptBlock' = {param($p1) Microsoft.PowerShell.Management\stop-process -Id $p1 -force -PassThru -ea stop}
                            }

                            $Reason = @()
                            foreach ($proc in $processes)
                            {
                                try
                                {
                                    $res = invoke-command @params -ArgumentList $proc
                                    $Status = "pass"
                                    $Reason += "$proc($($res.ProcessName))"
                                }
                                catch
                                {
                                    $Status = "fail"
                                    $Reason += "can't kill process $($proc): $($_.Exception.Message)"
                                }
                            }
                        }
                    }
                    elseif ($Method -match "external")
                    {
                        Write-Verbose "Using ExternalTools / Sysinternals"
                        Write-Verbose "BinPath: $BinPath"

                        if (!(Test-Path -Path "$BinPath\pskill.exe"))
                        {
                            $Status = "fail"
                            $Reason = "Binary pskill not found."
                        }
                        elseif (!(Test-Path -Path "$BinPath\pslist.exe"))
                        {
                            $Status = "fail"
                            $Reason = "Binary pslist not found."
                        }
                        elseif (!(Test-Path -Path "$BinPath\psservice.exe"))
                        {
                            $Status = "fail"
                            $Reason = "Binary psservice not found."
                        }
                        else
                        {
                            # Enable RemoteRegistry for the target
                            try
                            {
                                if (!$IsLocalhost -and !$NoRemoteRegistry -or (!$IsLocalhost -and $WhatIfPassed))
                                {
                                    $err = Enable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false -WhatIf:$WhatIfPassed

                                    $returnobject += $err
                                    $srr = Start-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false -WhatIf:$WhatIfPassed
                                    $returnobject += $srr
                                    $RemoteRegistryStarted = ($srr.status -match "pass")
                                }
                                else
                                {
                                    # assume RemoteRegistry is already started
                                    $RemoteRegistryStarted = $true
                                }

                                # pslist - check if multiple processes are running
                                if ($Name)
                                {
                                    if ($IsLocalhost)
                                    {
                                        $proc = Start-Process pslist.exe -CommandLine "-accepteula -nobanner $Name"
                                    }
                                    else
                                    {
                                        $proc = Start-Process pslist.exe -CommandLine "-accepteula -nobanner \\$target $Name"
                                    }
                                }
                                else
                                {
                                    if ($IsLocalhost)
                                    {
                                        $proc = Start-Process pslist.exe -CommandLine "-accepteula -nobanner $Pid"
                                    }
                                    else
                                    {
                                        $proc = Start-Process pslist.exe -CommandLine "-accepteula -nobanner \\$target $Pid"
                                    }
                                }

                                if ($proc.stdout | select-string "not" -quiet)
                                {
                                    $Reason = "Process not found"
                                    $Status = "fail"
                                }
                                elseif ($proc.stdout -match "Cannot connect" -or $proc.stdout -match "failed")
                                {
                                    $Reason = "Failed to connected to remote host"
                                    $Status = "fail"
                                }
                                else
                                {
                                    Write-Verbose "Process found"
                                    $MultipleProcesses = (($proc.stdout | measure -Line).Lines -gt 4)
                                    Write-Verbose "Process count: $($MultipleProcesses)"
                                    if ($MultipleProcesses -and !$StopAll)
                                    {
                                        $Reason = "multiple processes found, please use -stopall to stop all processes"
                                        $Status = "fail"
                                    }
                                    else
                                    {
                                        # pskill
                                        if ($Name)
                                        {
                                            if ($IsLocalhost)
                                            {
                                                $proc = Start-Process pskill.exe -CommandLine "-accepteula -nobanner $Name"
                                            }
                                            else
                                            {
                                                $proc = Start-Process pskill.exe -CommandLine "-accepteula -nobanner \\$target $Name"
                                            }
                                        }
                                        else
                                        {
                                            if ($IsLocalhost)
                                            {
                                                $proc = Start-Process pskill.exe -CommandLine "-accepteula -nobanner -t $Pid"
                                            }
                                            else
                                            {
                                                $proc = Start-Process pskill.exe -CommandLine "-accepteula -nobanner -t \\$target $Pid"
                                            }
                                        }

                                        if (($proc.stderr).Contains("verweigert") -or ($proc.stderr).Contains("denied"))
                                        {
                                            $Reason = "Access denied while stopping"
                                            $Status = "fail"
                                        }
                                        elseif (!($proc.stdout).Contains("Error") -and ($proc.stdout).contains("killed"))
                                        {
                                            $Reason = "Process stopped."
                                            $Status = "pass"
                                        }
                                        else
                                        {
                                            $Reason = "Unspecified error."
                                            $Status = "fail"
                                        }
                                        if ($proc.ExitCode -eq 0)
                                        {
                                            Write-Verbose "Successfully executed pskill on $target"
                                        }
                                        else
                                        {
                                            Write-Verbose  "Error while running pskill on $target"
                                        }
                                    }
                                }
                            }
                            catch
                            {
                                Write-Verbose "Error while enabling RemoteRegistry"
                                $Reason = "Error while enabling RemoteRegistry"
                                $Status = "fail"
                            }
                            try
                            {
                                if (!$IsLocalhost -and !$NoRemoteRegistry -and $RemoteRegistryStarted -or (!$IsLocalhost -and $WhatIfPassed))
                                {
                                    Write-Verbose "Cleanup RemoteRegistry"
                                    $srr = Stop-Service -ComputerName $target -Method external -Name "RemoteRegistry" -OnlineCheck:$false -WhatIf:$WhatIfPassed
                                    $returnobject += $srr
                                    $drr = Disable-RemoteRegistry -Method external -ComputerName $target -OnlineCheck:$false -WhatIf:$WhatIfPassed
                                    $returnobject += $drr
                                }
                            }
                            catch
                            {
                                Write-Verbose "Error while disabling RemoteRegistry"
                                $Reason = "Error while disabling RemoteRegistry"
                                $Status = "fail"
                            }
                        } #Binaries found

                    } #external

                } #online

                $returnobject += New-PowerSponseObject -Function $Function -Status $Status -Reason $Reason -Arguments $Arguments -ComputerName $target

            } # whatif

        } # each target

    } # params ok

    $returnobject
    Write-Verbose "Leaving $($MyInvocation.MyCommand)"

} #Stop-Process
