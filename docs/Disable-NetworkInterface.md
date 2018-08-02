---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Disable-NetworkInterface.md
schema: 2.0.0
---

# Disable-NetworkInterface

## SYNOPSIS
Disable a network interface.

## SYNTAX

```
Disable-NetworkInterface [[-ComputerName] <String[]>] [[-ComputerList] <String>] [-Method <String>]
 [[-Session] <PSSession[]>] [[-Credential] <PSCredential>] [[-InterfaceIndex] <String>]
 [[-InterfaceDescription] <String>] [-DisableAll] [-OnlineCheck] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Disable a network interface.

## EXAMPLES

### Example 1
```
PS> Get-NetworkInterface -InterfaceDescription "intel"


Time         : 19.01.2017 11:58:04
Function     : Get-NetworkInterface
ComputerName : localhost
Arguments    : InterfaceIndex: , InterfaceDescription: intel, OnlyIndex: False, OnlineCheck: True
Status       : pass
Reason       : {...}
```

Search for interfaces on the localhost of which its description contains "intel".

### Example 2
```
PS> Get-NetworkInterface -InterfaceDescription ".*wireless.*"


Time         : 19.01.2017 11:58:04
Function     : Get-NetworkInterface
ComputerName : localhost
Arguments    : InterfaceIndex: , InterfaceDescription: .*wireless.*, OnlyIndex: False, OnlineCheck: True
Status       : pass
Reason       : {...}
```

Search for interfaces on the localhost of which its description contains the regex ".*wireless.*".

### Example 3
```
PS> Get-NetworkInterface -ComputerName comp1 -InterfaceIndex 7


Time         : 19.01.2017 12:01:59
Function     : Get-NetworkInterface
ComputerName : comp1
Arguments    : InterfaceIndex: 7, InterfaceDescription: , OnlyIndex: False, OnlineCheck: True
Status       : pass
Reason       : {Index: 7...}
```

Search for interfaces of which its index is 7 on the remote host comp1.

### Example 4
```
PS> Get-NetworkInterface -ComputerName comp1 -Credential $creds -InterfaceDescription ".*"


Time         : 19.01.2017 12:04:28
Function     : Get-NetworkInterface
ComputerName : comp1
Arguments    : InterfaceIndex: , InterfaceDescription: .*, OnlyIndex: False, OnlineCheck: True
Status       : pass
Reason       : {...}
```

List every interface from the remote host comp1 and use alternate credentials ("Get-Credential").

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

### -Credential
Alternate credentials to use.

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

### -DisableAll
If multiple network interfaces were found disable them all. Otherwise, the
script aborts.

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

### -InterfaceDescription
Search string for interface description (also regex possible).

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

### -InterfaceIndex
Interface index number to search for.

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

### -Session
Use an existing PSSession to execute the commands.

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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
Method to use by the function.

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
