---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/New-CleanupPackage.md
schema: 2.0.0
---

# New-CleanupPackage

## SYNOPSIS
Creates a new cleanup package according to the given CoRe rule.

## SYNTAX

```
New-CleanupPackage [-RuleFile] <String> [[-ComputerName] <String>] [[-OutputPath] <String>]
 [[-PackageName] <String>] [-IgnoreMissing] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new cleanup package according to the given CoRe rule. All functions
from PowerSponse are put into one PowerShell script and all the commands from
the CoRe rule are put at the end. This allows offline deployment.

## EXAMPLES

### Example 1
```
PS> New-CleanupPackage -RuleFile .\rules\infection-2017-01-19.json
Wrote cleanup script to C:\Users\user\Cleanup-74862546-8dd6-4095-88b5-693c6dbaacc9.ps1
```

The command creates a new cleanup package with all the required functions and
cleanup commands for localhost.

## PARAMETERS

### -ComputerName
A list of computer names as comma separated list.

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

### -OutputPath
The path where the new cleanup PowerShell script should be written to.

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

### -PackageName
The filename for the new cleanup PowerShell script.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

Required: True
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

### -IgnoreMissing
{{Fill IgnoreMissing Description}}```yaml
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
