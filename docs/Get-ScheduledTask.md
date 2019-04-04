---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Get-ScheduledTask.md
schema: 2.0.0
---

# Get-ScheduledTask

## SYNOPSIS
Find scheduled tasks based on regex. 

## SYNTAX

```
Get-ScheduledTask [-ComputerName <String[]>] [-ComputerList <String>] [-Method <String>] [-BinPath <String>]
 [-Session <PSSession[]>] [-Credential <PSCredential>] [-NoRemoteRegistry] [-OnlineCheck]
 [-SearchString <String>] [-PrintXML] [-OnlyTaskName] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Find scheduled tasks based on a search string which also supports regex.

The command uses the Windows binary "schtask" for querying scheduled task on 
(remote) hosts. Therefore, no credential parameter is allowd and an 
elevated shell is needed using the required permissions on remote host.

## EXAMPLES

### Example 1
```
PS> Get-ScheduledTask -SearchString ".*-S-\d{1}-\d{1}" -OnlyTaskName


Time         : 06.01.2017 10:31:29
Action       : Get-ScheduledTask
ComputerName : localhost
Arguments    : TaskName: .*-S-\d{1}-\d{1}
Status       : pass
Reason       : \G2MUpdateTask-S-1-5-21-111111111-2222222222-333333333-444444 ; \G2MUploadTask-S-1-5-21-111111111-2222222222-333333333-444444
```

Search for scheduled tasks with the given regex and display only the task name.

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
Default value: False
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

### -PrintXML
Print XML of found scheduled tasks.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
Default value: False
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
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlyTaskName
Return only the task name without additional information.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchString
Search string to search for tasks. Use regex for matching.

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

### -OnlineCheck
Check if the target hosts are online. Disabling it speeds things up.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
