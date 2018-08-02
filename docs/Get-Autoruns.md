---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Get-Autoruns.md
schema: 2.0.0
---

# Get-Autoruns

## SYNOPSIS
Collect Autoruns output.

## SYNTAX

```
Get-Autoruns [[-ComputerName] <String[]>] [[-ComputerList] <String>] [[-OutputPath] <String>]
 [-NoRemoteRegistry] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Collect Autoruns output with Sysinternal's Autorunsc.
The CSV will be stored in the current directory by default and
the computer name is used as filename.

## EXAMPLES

### Example 1
```
PS> Get-Autoruns -ComputerName comp1
```

Collects Autoruns output from comp1 and stores CSV into current dir.

## PARAMETERS

### -ComputerList
File with a list of target computers.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
Position: 0
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

### -OutputPath
Output path for autoruns CSV file. If not specified, current directory is used.
The CSV file will have the filename according to the target name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
