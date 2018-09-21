# BUILD

## Testing

Run all the tests:

`Invoke-Pester .\test\`

To use the code coverage assessment use `-CodeCoverage`:

`$res = Invoke-Pester .\Pester\ -CodeCoverage ..\PowerSponse.psm1 -PassThru`

The result can be read in the following manner:

``` powershell
PS> $res.TotalCount
11
PS> $res.FailedCount
0
PS> $res.PassedCount
11
```

# Source Code Analyzer

`Invoke-ScriptAnalyzer -Path .\PowerSponse\`

## Generating Help

### Markdown Help
First time create markdown help with the following commands

``` powershell
# 1. Import module
Import-Module .\PowerSponse.psd1 -Force

# 2. Create new markdown help for module, otherwise use 3.
New-MarkdownHelp -Module PowerSponse -OutputFolder .\docs\ -WithModulePage -Force -HelpVersion "1.0.0.0"

# 3. Create new markdown help file for specific command
New-MarkdownHelp -Command Restart-Computer -OutputFolder .\docs\ -OnlineVersionUrl "https://github.com/swisscom/PowerSponse/blob/master/docs/Restart-Computer.md" 
```
For updating the markdown help use instead the following commands

``` powershell
Import-Module .\PowerSponse.psd1 -Force
Remove-Module microsoft.powershell.management
ipmo microsoft.powershell.management -NoClobber
Update-MarkdownHelp .\docs\
```

### PowerShell Help
Use the following command for creating a PowerShell help file (use `-force` to
update an existing external help file).

``` powershell
New-ExternalHelp -Path .\docs\ -OutputPath en-us\ -Force
```

## Tags file for PowerShell

### PowerShell
The following [ctags](http://ctags.sourceforge.net/ctags.html) command uses
only variables which come directly after a type declaration, e.g. \[string\]
var.

ctags.cnf (variables disabled through the regex)

```
--langdef=powershell
--langmap=powershell:.psm1.ps1
--regex-powershell=/function\s+(script:)?([a-zA-Z\-]+)/\2/m, method/i
--regex-powershell=/xxxxCommentxxxxx\s*\[.*\]\s*\$([a-zA-Z\-]+)/\1/v, variable/i
--regex-powershell=/xxxxCommentxxxxx\$global:([a-zA-Z\-]+)/\1/v, globalvariable/i
--exclude=test
--exclude=bin
```

ctags command

```
ctags -R --languages=powershell
```

### Pester

```
ctags -R --langdef=pester --langmap=pester:.ps1 --regex-pester="/describe\s+'(.*)'/\1/m, method/i"
```

Use `--excmd=number` for line numbers instead of the tag text.

## References
* [Pester](https://github.com/pester/Pester)
* [platyPS](https://github.com/PowerShell/platyPS)
* [New-ModuleManifest](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/new-modulemanifest)
* [Update-ModuleManifest](https://msdn.microsoft.com/powershell/reference/5.1/PowerShellGet/Update-ModuleManifest)
