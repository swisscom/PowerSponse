---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Get-PowerSponseRule.md
schema: 2.0.0
---

# Get-PowerSponseRule

## SYNOPSIS
Reads the specified CoRe rule and prints the result.

## SYNTAX

```
Get-PowerSponseRule [[-RuleFile] <String>] [[-method] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Reads the specified CoRe rule and prints the result. This can be used to test
the CoRe rule syntax.

## EXAMPLES

### Example 1
```
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

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

### -RuleFile
Rule file to read the rules.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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

### -method
Method to use by the function for parsing the CoRe rules.
If no method is given, use the file extension.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: xml, json

Required: False
Position: 2
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
