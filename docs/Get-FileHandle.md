---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Get-FileHandle.md
schema: 2.0.0
---

# Get-FileHandle

## SYNOPSIS
Get file handles for a process specified by the pid or by its name.

## SYNTAX

### ByProcessName (Default)
```
Get-FileHandle [-ComputerName <String[]>] [-ComputerList <String>] [-Method <String>] [-BinPath <String>]
 [-Session <PSSession[]>] [-Credential <PSCredential>] [-OnlineCheck <Boolean>] [-ProcessName <String>]
 [-HandlesByProcessName] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByProcessPid
```
Get-FileHandle [-ComputerName <String[]>] [-ComputerList <String>] [-Method <String>] [-BinPath <String>]
 [-Session <PSSession[]>] [-Credential <PSCredential>] [-OnlineCheck <Boolean>] [-ProcessPid <Int32>]
 [-HandlesByProcessName] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Get file handles for a process specified by the pid or by its name.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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

### -HandlesByProcessName
Define output format according to Sysinternal's PsHandle.
It specifies whether to use the process name to reading the handles.

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

### -Method
Method to use by the function.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: external

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

### -ProcessName
Process name to search for.

```yaml
Type: String
Parameter Sets: ByProcessName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessPid
Process PID to search for.

```yaml
Type: Int32
Parameter Sets: ByProcessPid
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
