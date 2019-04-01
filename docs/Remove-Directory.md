---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Remove-Directory.md
schema: 2.0.0
---

# Remove-Directory

## SYNOPSIS
Remove directories based on wildcards at the end of the path or based on regex.

## SYNTAX

```
Remove-Directory [[-ComputerName] <String[]>] [[-ComputerList] <String>] [[-Method] <String>]
 [[-Session] <PSSession[]>] [[-Credential] <PSCredential>] [[-Path] <String>] [-Recurse] [[-Regex] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove directories based on wildcards at the end of the path or based on regex.

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-Directory -ComputerName $target -path "C:\users\username\folder\"
```

Remove folder on remote host.

### Example 2
```powershell
PS C:\> Remove-Directory -ComputerName $target -path "C:\users\username\folder\" | select -ExpandProperty reason
```

Remove folder on remote host and select only the field 'reason'.
 
### Example 3
```powershell
PS C:\> remove-Directory -ComputerName $target -path C:\users\username\ -Recurse -Regex "fs\w{4}$" | select -ExpandProperty reason
```

Remove folder on remote host based on regex for folder name. Select only the
reason field to see full list of removed folders.

### Example 4

```powershell
PS C:\> remove-Directory -ComputerName $target -path C:\users\username\ -Recurse -Regex "fs\w{4}$" -WhatIf
```

Remove folder on remote host but this time only see what the command
would do using the `-WhatIf` parameter.

### Example 5

```powershell
PS C:\> remove-Directory -ComputerName host1,host2 -path "C:\users\*\appdta"
```

Remove folder on multiple remote host at once.

## PARAMETERS

### -ComputerList
List of target computers in a file.

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
List of target computers.

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
Position: Benannt
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credentials for remote computer.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
Method used for remote access.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: WinRM

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Path to the file (filter with -Regex).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
Should the search also include subfolders.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Benannt
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Regex
Regex used for filtering.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session
PSSession for remote access.

```yaml
Type: PSSession[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
Position: Benannt
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Keine


## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
