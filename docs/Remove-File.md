---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Remove-File.md
schema: 2.0.0
---

# Remove-File

## SYNOPSIS
Remove files based on wildcards at the end of the path or based on regex.

## SYNTAX

```
Remove-File [[-ComputerName] <String[]>] [[-ComputerList] <String>] [[-Method] <String>]
 [[-Session] <PSSession[]>] [[-Credential] <PSCredential>] [[-Path] <String>] [-Recurse] [[-Regex] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Remove files based on wildcards at the end of the path or based on regex.

## EXAMPLES

### Example 1
```powershell
PS C:\> remove-file -ComputerName $target -path "C:\users\username\evil.exe"
```

Remove file based on regex. First every file is searched which matchs the path
and the regex and then the remove function is called with the found files.


### Example 2
```powershell
PS C:\> remove-file -ComputerName $target -path "C:\users\username\" -Recurse -Regex "\\\w{3}\."
```

Remove file based on regex. First search for every file which matches the path
and the regex in all folders and subfolders and then remove the found files.

### Example 2
```powershell
PS C:\> remove-file -ComputerName $target -path "C:\users\username\" -Recurse -Regex "\\\w{3}\." | select -ExpandProperty reason
```

Remove file based on regex. First search for every file which matches the path
and the regex in all folders and subfolders and then remove the found files.
Select only the field 'reason' to see the full list of removed files.

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
