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
