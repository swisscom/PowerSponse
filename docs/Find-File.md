---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Find-File.md
schema: 2.0.0
---

# Find-File

## SYNOPSIS
Find files on remote host based on simple wildcards or with regex. Use the
command against one or multiple hosts.

## SYNTAX

```
Find-File [[-ComputerName] <String[]>] [[-ComputerList] <String>] [[-Method] <String>]
 [[-Session] <PSSession[]>] [[-Credential] <PSCredential>] [[-Path] <String>] [-Recurse] [[-Regex] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Find files on remote host based on simple wildcards or with regex. Use the
command against one or multiple hosts.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-File -ComputerName host1 -Path C:\users\*\*.exe
```

Search for .exe files within the users profile folder.

### Example 2
```powershell
PS C:\> $ret = find-file -Path C:\Users\username\appdata\ -Regex "\d{6}.exe" -Recurse
PS C:\> $ret
PS C:\> $ret | select -ExpandProperty reason
```

Search for files with given regex in all AppData subfolders on localhost.

### Example 3
```powershell
PS C:\> Find-File -Path C:\Users\*\ -Recurse -Regex "\\(.*)\\(\1)\.exe" | select -ExpandProperty reason
```

Search for files with given regex using backreference (name of exe is the same as the parent folder)
in all user folders on localhost. Emotet names its binaries like the folder namne in AppData.
However, there are many legitimate tools with this... so that's not an unique indicator.

## PARAMETERS

### -ComputerList
List of target computers in a text file

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
Target computer

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
Credentials used on remote host

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
Currently not used. Only WinRM is implemented.

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
Search path for files.

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
Recursive search

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
Regex pattern for file path

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
PowerShell session

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Keine

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
