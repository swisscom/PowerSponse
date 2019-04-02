# Contributing to PowerSponse

Great, you decided to contribute! That's awesome!

Please file an [issue](https://github.com/swisscom/PowerSponse/issues) if you
need a new feature or found an inconvenient "situation" (bug) or get the code
form Github, make a new branch, extend the functionality as its needed and
make a [pull request](https://github.com/swisscom/PowerSponse/pulls) if you
need a new feature or found an inconvenient "situation". See section
[What is PowerSponse?](README.md#what-is-powersponse) for an overview about
the repo structure.

Please use the guidelines as references when implementing new functions and
check current cmdlets how to use supporting functions.

* [PowerShell scripting best practices](https://blogs.technet.microsoft.com/pstips/2014/06/17/powershell-scripting-best-practices/)
* [Building-PowerShell-Functions-Best-Practices](http://ramblingcookiemonster.github.io/Building-PowerShell-Functions-Best-Practices/)
* [Strongly Encouraged Development Guidelines](https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx)
* [Approved Verbs for Windows PowerShell Commands](https://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx)
* [How to Write a PowerShell Module Manifest](https://msdn.microsoft.com/en-us/library/dd878337(v=vs.85).aspx)
* [Windows PowerShell: Writing Cmdlets in Script](https://technet.microsoft.com/en-us/library/ff677563.aspx)

Some general guidelines:

* Functions must support the common parameters (e.g. -WhatIf)
* Functions should support all methods: WMI, WinRM, External
* Functions must return PowerSponse objects to be able to concatenate the
  output of different commands
* Functions names must comply with the PowerShell approved verbs (see
  references below)
* Functions should not throw an exception instead the field "reason" should
  contain the error message
* Add Pester tests for new functionality in .\tests\Pester\
* Register the feature to the `$Repository` variable (see PowerSponse.psm1)

## Adding a new feature

1. Implement feature in respect to the guidelines mentioned above.
1. Add corresponding Pester tests where useful in /test/Pester.
1. Add the name of a new cmdlet which is used by the users to the
   **Export-ModuleMember** list at the end of the module file (.psm1).
1. Add the name of a new cmdlet to the **FunctionsToExport** list in the module
   description file (.psd1).
1. Add relevant notes to the [CHANGELOG](CHANGELOG.md).
1. Add a new markdown help file in /docs with examples. See [BUILD](BUILD.md)
   for information about generating the help file. 
1. Add new markdown help file to the overview in /docs/PowerSponse.md.
1. Update the external help file. See [BUILD](BUILD.md) for
   information about generating the help file. 
1. Update README if needed.
1. Update tag file if needed. See [BUILD](BUILD.md) for
   information about generating the tag file.

## Making a new Release

1. Update markdown help and external help file.
1. Run the Pester tests. See [BUILD](BUILD.md). All tests must pass.
1. Update CHANGELOG 
    * Update information according to the current release.
    * Add new **Unreleased** section and update the link for comparison.
    * Add the new version number in the old unreleased section.
    * Add the version comparison link to the current release changelog section.
    * Add the current date at the end of the new header row
1. Update **ModuleVersion** in the module description file (.psd1).
1. Commit the changes
1. Set a tag for the new version (e.g. "vx.x.x").
1. Push the tag and the code changes to the repo.
1. Add a new Github release and add release notes
1. Publish the new module version to PowerShell gallery
    * Make a clean folder for PowerSponse in the module path.
    * Add the psm1, psd1, Repository.ps1, the bin folder only with versioned
      files, the folder functions and the external help (en-us) to that
      PowerSponse module folder.
    * Run the following command to publish the module to the PowerShell gallery.
    ``` powershell
    Publish-Module -Name PowerSponse -NuGetApiKey <apiKey> 
    ```
1. Update release notes in PowerShellGallery

The module is currently located at https://www.powershellgallery.com/packages/PowerSponse.

