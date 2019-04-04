---
external help file: PowerSponse-help.xml
Module Name: PowerSponse
online version: https://github.com/swisscom/PowerSponse/blob/master/docs/Get-PowerSponseRepository.md
schema: 2.0.0
---

# Get-PowerSponseRepository

## SYNOPSIS
Reads the current PowerSponse repository.

## SYNTAX

```
Get-PowerSponseRepository [<CommonParameters>]
```

## DESCRIPTION
Reads the current PowerSponse repository. The repository contains the
defintion for the functions which are available for using inside CoRe rules 
and the corresponding commands `Invoke-PowerSponse` or `New-CleanupPackage`.

## EXAMPLES

### Example 1
```
PS C:\> Get-PowerSponseRepository
```

Read the PowerSponse repository configuration. The repository defines the commands 
which could be used by `Invoke-PowerSponse` or `New-CleanupPackage`.

### Example 2
```
PS C:\> (Get-PowerSponseRepository)['ProcessItem']
```

Read the PowerSponse configuration for the ProcessItem actions. The PowerSponse 
repository defines the commands which could be used by `Invoke-PowerSponse` 
or `New-CleanupPackage`.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
