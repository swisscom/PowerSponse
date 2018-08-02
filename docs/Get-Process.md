---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Get-Process.md
schema: 2.0.0
---

# Get-Process

## SYNOPSIS
Find processes based on the on user supplied pid or process name information.
Use regex for finding based on patterns.

## SYNTAX

### BySearchString (Default)
```
Get-Process [-ComputerName <String[]>] [-ComputerList <String>] [-Method <String>] [-BinPath <String>]
 [-Session <PSSession[]>] [-Credential <PSCredential>] [-SearchString <String>] [-OutputFormat <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ByPid
```
Get-Process [-ComputerName <String[]>] [-ComputerList <String>] [-Method <String>] [-BinPath <String>]
 [-Session <PSSession[]>] [-Credential <PSCredential>] [-Pid <Int32>] [-OutputFormat <String>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The **Get-Process** function finds processes on the target machine based on
the _-Pid_ or _-SearchString_ parameters. It also searches the executable path
if available. This allows search for processes started from e.g. AppData.

By default WMI is used for quering the information. You can also use the
method ( _-method_ ) "external" for using pslist.

Use the parameter _-Credential_ to supply different credentials.

## EXAMPLES

### Example 1
```
PS> Get-Process -SearchString "p.*shell"


Time         : 15.01.2017 18:05:25
Function     : Get-Process
ComputerName : localhost
Arguments    : SearchString p.*shell
Status       : pass
Reason       : {4332 ; powershell.exe ; ...
```

This command searches for everything with the given pattern in the process
name or in the executable path.

## PARAMETERS

### -BinPath
Binary path for external tools.

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
File with a list of computer names to process.

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
A list of computer names to process (comma separated).

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

### -Credential
Credentials to use against remote host.

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

### -Session
PSSession for using instead of credentials.

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

### -Method
Method to use.

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

### -OutputFormat
...

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

### -Pid
Search for a process id.

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

### -SearchString
Search for process name or a part in the executable 
path according to the given searchstring. Regex can 
be used for the searchstring.

```yaml
Type: String
Parameter Sets: BySearchString
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

## OUTPUTS

### PowerSponse Object

## NOTES

## RELATED LINKS
