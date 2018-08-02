---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Invoke-PowerSponse.md
schema: 2.0.0
---

# Invoke-PowerSponse

## SYNOPSIS
Read the CORE rules and invokes all defined cleanup commands.

## SYNTAX

```
Invoke-PowerSponse [-RuleFile <String>] [-ComputerName <String[]>] [-ComputerList <String>]
 [-OnlineCheck <Boolean>] [-IgnoreMissing] [-PrintCommand] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Read the CORE rules and invokes all defined cleanup commands.

## EXAMPLES

### Example 1
```
PS C:\> Invoke-PowerSponse -ComputerName comp1 -Rule dridex-201606.xml
```

This command reads the rule dridex-201606.xml and invokes all the
corresponding functions.

## PARAMETERS

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
Default value: False
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

### -RuleFile
CoRe rule file.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: False
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

### -PrintCommand
Print the commands which Invoke-PowerSponse would executed.
It's like an extended -WhatIf to show the exact commands.

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

### -IgnoreMissing
Proceed despite missing action types in the repository.```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
