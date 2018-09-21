---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Invoke-PsExec.md
schema: 2.0.0
---

# Invoke-PsExec

## SYNOPSIS
Invoke PsExec on remote host and execute given binary with specified command
line.

## SYNTAX

```
Invoke-PsExec [[-ComputerName] <String[]>] [[-Program] <String>] [[-CommandLine] <String>] [-AsSystem]
 [-CopyProgramToRemoteSystem] [-ForceCopyProgramToRemoteSystem] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Invoke PsExec on remote host and execute given binary with specified command
line.

`Invoke-PsExec` returns a tuple with both the PowerSponse objects and the
second with the program output (exit code, stdout, stderr).

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-PsExec -ComputerName $target -Program ipconfig -CommandLine "/all"
```

Start ipconifig on remote host and display output.

### Example 2
```powershell
PS C:\> $ps, $return = Invoke-PsExec -ComputerName $target -Verbose -Program ipconfig -CommandLine "/all"
```

`Invoke-PsExec` returns a tuple: the PowerSponse objects (pass/fail,
timestamp, ...), here $ps and the exit code/stdout/stderr from the program
execution, here $return.

## PARAMETERS

### -AsSystem
Should the remote command be execute with system privileges.

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

### -CommandLine
Command line used for the remote command.

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

### -ComputerName
Target computer.

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

### -CopyProgramToRemoteSystem
If the binaries should be copied to the remote host.
Used for e.g. autoruns execution on remote host. If flag is not used the
binary must be in the path.

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

### -ForceCopyProgramToRemoteSystem
Force the copy to remote host.

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

### -Program
Program to execute on remote host.

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
