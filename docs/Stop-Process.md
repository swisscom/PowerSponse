---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Stop-Process.md
schema: 2.0.0
---

# Stop-Process

## SYNOPSIS
Stop a process based on regex.

## SYNTAX

### ByName (Default)
```
Stop-Process [-ComputerName <String[]>] [-ComputerList <String>] [-Method <String>] [-BinPath <String>]
 [-Session <PSSession[]>] [-Credential <PSCredential>] [-NoRemoteRegistry] [-OnlineCheck <Boolean>]
 [-Name <String>] [-StopAll] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByPid
```
Stop-Process [-ComputerName <String[]>] [-ComputerList <String>] [-Method <String>] [-BinPath <String>]
 [-Session <PSSession[]>] [-Credential <PSCredential>] [-NoRemoteRegistry] [-OnlineCheck <Boolean>]
 [-Id <Int32>] [-StopAll] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Stop a process.

## EXAMPLES

### Example 1
```
PS C:\> stop-Process -Name evil
```

Stop process named evil

### Example 2
```
PS C:\> stop-Process -Name "\\\w{3}.exe" -ComputerName $target
```

Stop process named with given regex pattern on remote host.

## PARAMETERS

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BinPath
Binary path for using with external tools.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerList
File with a list of target computers.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
A list of computer names as comma separated list.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Alternate credentials to use.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlineCheck
Check if the target hosts are online. Disabling it speeds things up.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session
Use an existing PSSession to execute the commands.

```yaml
Type: PSSession[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StopAll
If multiple processes are found stop all. Otherwise the execution is abort.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
Method to use by the function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Name of the process. Use regex for matching.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRemoteRegistry
Do not enable RemoteRegistry. By default, if needed, RemoteRegistry will be enabled before running commands and disabled afterwards.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
PID of process to stop.

```yaml
Type: Int32
Parameter Sets: ByPid
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
