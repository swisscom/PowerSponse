Set-StrictMode -Version latest

$BasePath = "$PSScriptRoot\..\..\"

Import-Module -Force $BasePath\PowerSponse.psm1

function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

Describe 'Stop-Service' {
	if(!(Test-Path "$BasePath\bin\psservice.exe")) {
		Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
	}
	Context 'Error' {
		It 'stop service without any parameter' {
			stop-Service | select -expandproperty reason | Should match "provide a service name"
		}

		It 'stop service without method but with service name' {
			stop-Service -Name "RemoteRegistry" | select -expandproperty reason | Should match "service already stopped"
		}

		It 'stop service with method but without service name' {
			stop-Service -Method wmi | select -expandproperty reason | Should match "provide a service name"
		}

		It 'stop service and without permissions with offline host using wmi' {
			stop-Service -Method wmi -Name "RemoteRegistry" -ComputerName notexistinghost | select -expandproperty reason | Should Match "offline"
		}

		It 'stop already stopped service with method and servicename but without permissions using wmi' {
			stop-Service -Method wmi -Name "RemoteRegistry" | select -expandproperty reason | Should Match "service already stopped"
		}

		It 'stop already stopped service with method and servicename but without permissions using psservice' {
			stop-Service -Method external -Name "RemoteRegistry" | select -expandproperty reason | Should Match "access denied"
		}

		It 'stop running service without permissions using wmi' {
			stop-Service -Method external -Name "WSearch" | select -expandproperty reason | Should Match "access denied"
		}

		It 'stop running service without permissions using psservice' {
			stop-Service -Method wmi -Name "WSearch" | select -expandproperty reason | Should Match "access denied"
		}
	}
	Context 'Valid' {
		It 'stop service with permissions using wmi' {
			if(-not $(Test-IsAdmin)) {
				Set-TestInconclusive "Test case needs local administrator privileges."
			}
			# todo
		}
		It 'stop service with permissions using psservice' {
			if(-not $(Test-IsAdmin)) {
				Set-TestInconclusive "Test case needs local administrator privileges."
			}
			# todo
		}
	}
}

Describe 'Start-Service' {
	if(!(Test-Path "$BasePath\bin\psservice.exe")) {
		Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
	}
	Context 'Error' {
		It 'start service without any parameter' {
			Start-Service | select -expandproperty reason | Should match "provide a service name"
		}

		It 'start service with method but without service name' {
			start-Service -Method wmi | select -expandproperty reason | Should match "provide a service name"
		}

		It 'start service and without permissions with offline host using wmi' {
			start-Service -Method wmi -Name "RemoteRegistry" -ComputerName notexistinghost | select -expandproperty reason | Should Match "offline"
		}

		It 'start service with method and servicename but without permissions using wmi' {
			start-Service -Method wmi -Name "RemoteRegistry" | select -expandproperty reason | Should Match "access denied"
		}

		It 'start service without permissions using psservice' {
			start-Service -Method external -Name "RemoteRegistry" | select -expandproperty reason | Should Match "access denied"
		}

		It 'start running service without permissions using wmi' {
			start-Service -Method wmi -Name "WSearch" | select -expandproperty reason | Should Match "service already started"
		}
	}
	Context 'Valid' {
		It 'start service with permissions using wmi' {
			if(-not $(Test-IsAdmin)) {
				Set-TestInconclusive "Test case needs local administrator privileges."
			}
			# todo
		}
		It 'start service with permissions using psservice' {
			if(-not $(Test-IsAdmin)) {
				Set-TestInconclusive "Test case needs local administrator privileges."
			}
			# todo
		}
	}
}

Describe 'Get-Process' {

	Context 'Error' {
		It 'without any parameter' {
			get-process | select -expandproperty reason | Should Match "no process name"
		}
		It 'unknown processname using wmi' {
			get-process -SearchString "mysuperunknownprocess" | select -expandproperty reason | Should Match "no process found"
		}
		It 'unknown processname and nonexisting computername using wmi' {
			get-process -SearchString "mysuperunknownprocess" -ComputerName notexisting | select -expandproperty reason | Should Match "offline"
		}
		It 'unknown processname using pslist' {
			if(-not $(Test-IsAdmin)) {
				Set-TestInconclusive "Test case needs local administrator privileges."
			}
			get-process -SearchString "mysuperunknownprocess" -Method external | ? {$_.Function -match "get-process"} | select -expandproperty reason | Should Match "Process not found"
		}
	}
	Context 'Valid' {
		BeforeAll {
			# cleanup
			Microsoft.PowerShell.Management\Stop-process -Name "calc" -ErrorAction SilentlyContinue
		}
		It 'find calc' {
			Microsoft.PowerShell.Management\start-process calc.exe
			get-process -SearchString "calc" | ? {$_.Function -match "get-process"} | select -expandproperty reason | Should belike "*; calc.exe*"
			Microsoft.PowerShell.Management\Stop-process -ProcessName "calc" -ErrorAction SilentlyContinue
		}
		It 'find two calc' {
			Microsoft.PowerShell.Management\start-process calc.exe
			Microsoft.PowerShell.Management\start-process calc.exe
			get-process -SearchString "calc" | ? {$_.Function -match "get-process"} | select -expandproperty reason | Should belike "*; calc.exe*"
			Microsoft.PowerShell.Management\Stop-process -ProcessName "calc" -ErrorAction SilentlyContinue
			Microsoft.PowerShell.Management\Stop-process -ProcessName "calc" -ErrorAction SilentlyContinue
		}
	}
}

Describe 'start-process' {
	Context 'valid' {
		It 'start ipconfig without arguments' {
			$ret = start-process ipconfig
			$ret.exitcode | Should Be 0
			($ret.stdout -split "`n")[1] | Should BeLike "Windows-IP-*"
			$ret.stderr | Should BeNullOrEmpty
		}

		It 'start psexec with wrong arguments' {
			$ret = start-process psexec.exe -CommandLine "-asdf"
			$ret.exitcode | Should Be -1
			($ret.stdout -split "`n")[1] | Should BeLike "PsExec v*"
			$ret.stderr | Should BeNullOrEmpty
		}
	}
}

Describe 'Stop-Process' {
	BeforeEach {
		#$res = Microsoft.PowerShell.Management\Stop-process -Name "calc" -ErrorAction SilentlyContinue
	}
	Context 'Error' {
		It 'without any parameter' {
			Stop-Process | select -expandproperty reason | should Match "no process name"
		} 

		It 'unknown process name without method' {
			Stop-Process -Name "xyasdfjalsjdfjasdf.exe" | select -expandproperty reason | Should Match "no process"
		}

		It 'unknown process name with WMI' {
			Stop-Process -Name "xyasdfjalsjdfjasdf.exe" | select -expandproperty reason | Should Match "no process"
		}

		It 'wrong process name with pskill' {
			Stop-Process -Name "xyasdfjalsjdfjasdf.exe" -method external | select -expandproperty reason | Should Match "process not found"
		}

		It 'multiple processes without stopall using wmi' {
			$res = Microsoft.PowerShell.Management\start-process calc.exe
			$res2 = Microsoft.PowerShell.Management\start-process calc.exe
			Stop-Process -Name "calc" -Method wmi | select -expandproperty reason | should match "multiple processes"
			Microsoft.PowerShell.Management\Stop-Process -Name "calc"
		}

		It 'localhost AND credential using wmi' {
			$secpasswd = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
			$creds = New-Object System.Management.Automation.PSCredential ("username", $secpasswd)
			Stop-Process -Name "xyasdfjalsjdfjasdf.exe" -Method wmi -Credential $creds | select -expandproperty reason | Should Match "localhost and WMI and"
		}

		It 'multiple processes without stopall using pskill' {
			$res = Microsoft.PowerShell.Management\start-process calc.exe
			$res2 = Microsoft.PowerShell.Management\start-process calc.exe
			Stop-Process -Name "calc" -Method external | select -expandproperty reason | should match "multiple processes found, please"
			{ Microsoft.PowerShell.Management\Stop-Process -Name "calc" -ea stop} | should not throw "Cannot find a process"
		} 

	} 
	Context 'Valid' {
		It 'Stop multiple process with name calc.exe with stopall on localhost using wmi' {
			{ Microsoft.PowerShell.Management\get-process calc -ea stop } | should throw "Cannot find a process"
			Microsoft.PowerShell.Management\start-process calc.exe
			Microsoft.PowerShell.Management\start-process calc.exe
			Microsoft.PowerShell.Management\start-process calc.exe
			$res = Stop-Process -Name "calc" -Method wmi -stopall
			($res | measure).count | should be 1
 			$count = (($res | select -expandproperty reason) -split " " | select-string "PID" | measure).count
			$count | should be 3
			{ Microsoft.PowerShell.Management\get-process calc -ea stop } | should throw "Cannot find a process"
		} 

		It 'Stop single process with name calc.exe on localhost using WMI' {
			{ Microsoft.PowerShell.Management\get-process calc -ea stop } | should throw "Cannot find a process"
			Microsoft.PowerShell.Management\start-process calc.exe
			$res = Stop-Process -Name "calc" -Method wmi
			($res | measure).count | should be 1
			($res | select -expandproperty status ) | should belike "pass"
			$res | select -expandproperty reason | should belike "Process(es) stopped: *"
			{ Microsoft.PowerShell.Management\get-process calc -ea stop } | should throw "Cannot find a process"
		} 

		It 'Stop single process with id on localhost using WMI' {
			{ Microsoft.PowerShell.Management\get-process calc -ea stop  } | should throw "Cannot find a process"
			Microsoft.PowerShell.Management\start-process calc.exe
			$res = Microsoft.PowerShell.Management\get-process "calc"
			$res = Stop-Process -Pid $res.id -Method wmi
			($res | measure).count | should be 1
			$res | select -expandproperty status | should belike "pass"
			$res | select -expandproperty reason | should belike "Process(es) stopped: *"
			{ Microsoft.PowerShell.Management\get-process calc -ea stop  } | should throw "Cannot find a process"
		} 

		It 'Stop multiple process with name calc.exe with stopall on localhost using pskill' {
			{ Microsoft.PowerShell.Management\get-process calc  -ea stop } | should throw "Cannot find a process"
			Microsoft.PowerShell.Management\start-process calc.exe
			Microsoft.PowerShell.Management\start-process calc.exe
			Microsoft.PowerShell.Management\start-process calc.exe
			$res = Stop-Process -Name "calc" -Method external -stopall
 			$res | select -expandproperty reason | should match "Process stopped."
			{ Microsoft.PowerShell.Management\get-process calc  -ea stop } | should throw "Cannot find a process"
		}

		It 'Stop single process with id on localhost using pskill' {
			{ Microsoft.PowerShell.Management\get-process calc  -ea stop } | should throw "Cannot find a process"
			Microsoft.PowerShell.Management\start-process calc.exe
			$res = Microsoft.PowerShell.Management\get-process "calc"
			$res = Stop-Process -Pid $res.id -Method external
			$res | select -expandproperty reason | should match "Process stopped."
			($res | measure).count | should be 1
			{ Microsoft.PowerShell.Management\get-process calc -ea stop } | should throw "Cannot find a process"
		} 

		It 'Stop single process with name on localhost using pskill' {
			{ Microsoft.PowerShell.Management\get-process calc -ea stop } | should throw "Cannot find a process"
			Microsoft.PowerShell.Management\start-process calc.exe
			$res = Stop-Process -Name calc -Method external
			$res | select -expandproperty reason | should match "Process stopped."
			($res | measure).count | should be 1
			{ Microsoft.PowerShell.Management\get-process calc -ea stop } | should throw "Cannot find a process"
		} 
	} 
} 

Describe 'Disable-RemoteRegistry' {

	Context 'Errors' {
		It 'without parameters' {
			Disable-RemoteRegistry | select -expandproperty reason | Should Match 'denied'
		}
		It 'without permissions on localhost using WMI' {
			if($(Test-IsAdmin)) {
 				Set-TestInconclusive "Test case must not use local administrator privileges."
			}
			Disable-RemoteRegistry -Method wmi  | select -expandproperty reason | Should match "denied"
		}
		It 'without permissions on localhost using external tools' {
			if(!(Test-Path "$BasePath\bin\psservice.exe")) {
				Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
			}
			Disable-RemoteRegistry -Method external | select -expandproperty reason | Should match "denied"
		}

	}

	Context 'Valid' {
		It 'Disable RemoteRegistry with valid local admin on localhost using WMI' {
			if(-not $(Test-IsAdmin)) {
				Set-TestInconclusive "Test case needs local administrator privileges."
			}
			# set service to manual value
			$res = Get-WmiObject Win32_service -Filter "name='RemoteRegistry'" -ComputerName localhost
			$res.ChangeStartMode('manual')
			$res = Get-WmiObject Win32_service -Filter "name='RemoteRegistry'" -ComputerName localhost
			$res.startmode | Should Be 'manual'
			Disable-RemoteRegistry -Method wmi | select status | Should Match "pass"
			Disable-RemoteRegistry -Method wmi | select -expandproperty reason | Should Match "disabled"
			$res = Get-WmiObject Win32_service -Filter "name='RemoteRegistry'" -ComputerName localhost
			$res.startmode | Should Be 'disabled'
		}
	}
}

Describe 'Enable-RemoteRegistry' {
	Context 'Error' {
		It 'without parameters' {
			Enable-RemoteRegistry | select -expandproperty reason | should match "denied"
		}

		It 'without permission using WMI' {
			Enable-RemoteRegistry -Method wmi | select -expandproperty reason | Should match "Access denied"
		} 

		It 'without permission using psservice' {
			if(!(Test-Path "$BasePath\bin\psservice.exe")) {
				Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
			}
			if($(Test-IsAdmin)) {
 				Set-TestInconclusive "Test case must not use local administrator privileges."
			}
			(Enable-RemoteRegistry -Method external).reason | Should match "Access denied"
		} 

	} 
	Context 'Valid' {
		It 'Enable RemoteRegistry with valid local admin on localhost using WMI' {
			if(-not $(Test-IsAdmin)) {
 				Set-TestInconclusive "Test case needs local administrator privileges."
			}
			Enable-RemoteRegistry -Method wmi | select -expandproperty reason | Should match "enabled"
		}
	}
}

Describe 'Enable-Service' {
	# todo cleanup and error handling
	Context 'Error' {
		It 'enable service without method' {
			enable-Service | select -expandproperty reason | Should match "provide a service name"
		}

		It 'enable service with method but without service name' {
			enable-Service -Method wmi | select -expandproperty reason | Should match "provide a service name"
		}

		It 'enable service with service name but without method and without startuptype' {
			enable-Service -Name 'noname' | select -expandproperty reason  | Should match "specifiy the startuptype"
		}

		It 'enable service with wrong startuptype' {
			{ Enable-Service -Name "noname" -StartupType asdf } | Should Throw "Cannot validate"
		} 

		It 'enable service with unknown service name but with startuptype' {
			enable-Service -Name "noname" -StartupType 'manual' | select -expandproperty reason | Should match "No service"
		}

		It 'enable service without permissions using wmi' {
			enable-Service -Name 'RemoteRegistry' -StartupType manual -Method wmi | select -expandproperty reason | Should match "Access denied"
		} 

		It 'enable service without permissions using psservice' {
			if(!(Test-Path "$BasePath\bin\psservice.exe")) {
				Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
			}
			enable-Service -Name 'RemoteRegistry' -Method external | select -expandproperty reason | Should match "specifiy the startuptype"
		}

		It 'enable service without permissions using psservice' {
			if(!(Test-Path "$BasePath\bin\psservice.exe")) {
				Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
			}
			enable-Service -Name 'RemoteRegistry' -Method external -StartupType "manual" | select -expandproperty reason | Should match "Access denied"
		}
	} 
} 

Describe 'Disable-Service' {
	Context 'Error' {
		It 'disable service without method' {
			disable-Service | select -expandproperty reason | Should match "provide a service name"
		}

		It 'disable service with method but without service name' {
			disable-Service -Method wmi | select -expandproperty reason | Should match "provide a service name"
		}

		It 'disable service without permissions using wmi' {
			disable-Service -Name 'RemoteRegistry' -Method wmi | select -expandproperty reason | Should match "Access denied"
		}

		It 'Disable service without permissions with external tools and wrong binpath' {
			if(!(Test-Path "$BasePath\bin\psservice.exe")) {
				Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
			}
			Disable-Service -Name 'RemoteRegistry' -Method external -BinPath "C:\system" | select -expandproperty reason | Should match "Binary psservice not found"
		} 

		It 'Disable service without permissions with external tools' {
			if(!(Test-Path "$BasePath\bin\psservice.exe")) {
				Set-TestInconclusive "Binaries must be available in binary path (BinPath). Nothing found in $($BasePath)bin\"
			}
			Disable-Service -Name 'RemoteRegistry' -Method external | select -expandproperty reason | Should match "Access denied"
		} 
	}
#	Context 'Valid' {
#		It 'Test with valid service name and method' {
#			if(!$(Test-IsAdmin)) {
#				Throw "Test case requires local administrator privileges."
#			}
#			Disable-Service -Method wmi -Name 'RemoteRegistry' | Should Be "disabled"
#		} 
#	} 
}

Describe 'Edit-ScheduledTask' {
	InModuleScope PowerSponse {
		Context 'Error' {
			It 'without argument' {
				Edit-ScheduledTask | select -expandproperty reason | Should Match "provide a task name"
			}

			It 'no task state' {
				Edit-ScheduledTask -SearchString "any-task-but-not-me" | select -expandproperty reason | Should Match "provide the.*task state"
			}

			It 'offline host' {
				Edit-ScheduledTask -SearchString "any-task-but-not-me" -TaskState enable -ComputerName not-existing-super-computer | select -expandproperty reason | Should Match "offline"
			}

			It 'localhost and invalid task' {
				Edit-ScheduledTask -SearchString "any-task-but-not-me" -TaskState enable -NoRemoteRegistry | select -expandproperty reason | Should Match "task not found"
			}

			It 'localhost and invalid task and onlinecheck set to true' {
				$ret = Edit-ScheduledTask -SearchString "any-task-but-not-me" -TaskState enable -NoRemoteRegistry
				$ret | select -expandproperty reason | Should Match "Task not found"
				$ret | select -expandproperty arguments | Should Match "OnlineCheck: true"
			}

			It 'localhost and invalid task and OnlineCheck = false' {
				Edit-ScheduledTask -SearchString "any-task-but-not-me" -NoRemoteRegistry -TaskState enable -OnlineCheck $false | select -expandproperty arguments | Should Match "OnlineCheck: false"
			}

		} #context error

	} # InModuleScope powersponse

} # Edit-ScheduledTask

Describe 'Get-Target' {
	InModuleScope PowerSponse {
		Context 'Errors' {
			It 'throw when file not exist' {
				{ Get-Target "Comp1" .\unknownfile.txt } | Should Throw "File .\unknownfile.txt not found"
			}

			It 'Valid computer name with numbers but with not existing file' {
				{ Get-Target "100" .\unknownfile.txt } |  Should Throw "File .\unknownfile.txt not found"
			}

			It 'not existing file' {
				{ Get-Target -ComputerList .\unknownfile2.txt } |  Should Throw "File .\unknownfile2.txt not found"
			}

			It 'Valid computer name with two computer names as one string'  {
				{ Get-Target "Comp1, Comp2" .\unknownfile.txt } | Should Throw "File .\unknownfile.txt not found"
			}
		}

		Context 'Valid' {
			It 'Valid computer name with numbers' {
				Get-Target "100" |  Should match "100"
			}

			It 'Valid computer name with two computer names as one string'  {
				Get-Target "Comp1, Comp2" | Should Be "Comp1, Comp2"
			}

			It 'Valid computername parameter with two different computer names'  {
				[string[]]$gr = @('Comp1', 'Comp2')
				($gr | measure).count | Should Be 2
				$gt = Get-Target Comp1,Comp2
				($gt | measure).count | Should Be 2
				diff $gr $gt | Should BeNullOrempty
				$gr | Should be $gt
			}

			It 'Valid computer name with three different computer names and one duplicate'  {
				[string[]]$gr = @('Comp1', 'Comp2', 'Comp1') | select -unique
				($gr | measure).count | Should Be 2
				$gt = Get-Target Comp1,Comp2, Comp1
				($gt | measure).count | Should Be 2
				diff $gr $gt | Should BeNullOrempty
				$gr | Should Be $gt
			}

			It 'Valid computer list file with one entry' {
				"target1" | Out-File -FilePath TestDrive:\targets.txt
				Get-Target -ComputerList TestDrive:\targets.txt | Should Be "target1"
			}

			It 'Valid computer list file with one entry and one ComputerName' {
				"target1" | Out-File -FilePath TestDrive:\targets.txt
				$gt = Get-Target Comp1 -ComputerList TestDrive:\targets.txt
				($gt | measure).count | Should Be 2
				$gt[0] | Should Be "Comp1"
				$gt[1] | Should Be "target1"
			}

			It 'Valid computer list file with two entry and two ComputerNames, one as duplicate' {
				"target1" | Out-File -FilePath TestDrive:\targets.txt
				"target2" | Out-File -FilePath TestDrive:\targets.txt -Append
				$gt = Get-Target Comp1, target1 -ComputerList TestDrive:\targets.txt
				($gt | measure).count | Should Be 3
				$gt[0] | Should Be "Comp1"
				$gt[1] | Should Be "target1"
				$gt[2] | Should Be "target2"
			}

			It 'Valid computer listfile with two entry' {
				"target1" | Out-File -FilePath TestDrive:\targets.txt
				"target2" | Out-File -FilePath TestDrive:\targets.txt -Append
				$gc = gc TestDrive:\targets.txt
				$gt = Get-Target -ComputerList TestDrive:\targets.txt
				(diff -ReferenceObject $gc -DifferenceObject $gt) | Should BeNullOrempty
			}

			It 'Valid computer listfile with three entry' {
				"target1" | Out-File -FilePath TestDrive:\targets.txt
				"target2" | Out-File -FilePath TestDrive:\targets.txt -Append
				"target3" | Out-File -FilePath TestDrive:\targets.txt -Append
				$gc = gc TestDrive:\targets.txt
				$gt = Get-Target -ComputerList TestDrive:\targets.txt
				(diff -ReferenceObject $gc -DifferenceObject $gt) | Should BeNullOrempty
			}

			It 'Valid computer listfile with three entry and one duplicate' {
				"target1" | Out-File -FilePath TestDrive:\targets.txt
				"target2" | Out-File -FilePath TestDrive:\targets.txt -Append
				"target2" | Out-File -FilePath TestDrive:\targets.txt -Append
				$gc = (gc TestDrive:\targets.txt | select -unique)
				$gt = Get-Target -ComputerList TestDrive:\targets.txt
				(diff -ReferenceObject $gc -DifferenceObject $gt) | Should BeNullOrempty
			}

			It 'Different computer list files for comparison, must be different' {
				"target1" | Out-File -FilePath TestDrive:\targets.txt
				"target2" | Out-File -FilePath TestDrive:\targets.txt -Append
				$gc = gc TestDrive:\targets.txt
				"target3" | Out-File -FilePath TestDrive:\targets.txt -Append
				$gt = Get-Target -ComputerList TestDrive:\targets.txt
				(diff -ReferenceObject $gc -DifferenceObject $gt) | Should Not BeNullOrempty
			}

			It 'Empty ComputerList' {
				"" | Out-File -FilePath TestDrive:\targets.txt
				Get-Target -ComputerList TestDrive:\targets.txt | Should Be "localhost"
			}

			It 'Empty file' {
				Set-Content -Path TestDrive:\targets.txt -Value ""
				Get-Target -ComputerList TestDrive:\targets.txt | Should Be "localhost"
			}

		} #get-target context valid
	}
} # Get-Target

Describe 'Find-File'{
	Context 'error' {
		It 'no argument' -skip {
			find-file | Should Match "provide file path"
		}
		# todo
	}

	Context 'valid' {
		It 'nonexisting file' -skip {
			find-file -staticfilepath C:\windows\ -variablefilepath temp -variablefilename "targets123.txt" | select -expandproperty reason | Should Not Match "file not found"
		}
		It 'valid filename' -skip {
			"target1" | Out-File -FilePath C:\windows\temp\targets.txt
			find-file -staticfilepath C:\windows\ -variablefilepath temp -variablefilename "targets.txt" | select -expandproperty reason | Should Not Match "file not found"
		}
	}
}

#Function disabled because currently only WinRM is implemented
#Describe 'Get-Certificate' {
#	Context 'Error' {
#		It 'no search string' {
#			Get-Certificate | select -expandproperty reason | Should Match "no search string"
#		}
#
#		It 'no search string and offline host' {
#			Get-Certificate -ComputerName asdfaksdfjlasdf | select -expandproperty reason | Should Match "no search string"
#		}
#
#		It 'unknown searchstring and localhost' {
#			Get-Certificate -SearchString asdfaksdfjlasdf | select -expandproperty reason | Should Match "no certificate found"
#		}
#
#		It 'search string and offline host' {
#			Get-Certificate -SearchString asdfaksdfjlasdf -ComputerName asdfaksdfjlasdf| select -expandproperty reason | Should Match "offline"
#		}
#	}
#	Context 'valid' {
#		It 'valid certificates mozilla' {
#			$ret =  Get-Certificate -SearchString "mozilla"
#			($ret | select -ExpandProperty reason | measure).count | Should Be 2
#			($ret | select -ExpandProperty reason)[0].friendlyname | Should Be fraudulent
#		}
#	}
#}

Describe 'Get-NetworkInterface' {
	Context 'error' {
		It 'no interface information' {
			Get-NetworkInterface | select -expandproperty reason | Should match "no search information"
		}
		It 'offline host' {
			$ret = Get-NetworkInterface -ComputerName xxxxxxx -InterfaceDescription wan
			$ret.status | Should Match "fail"
			$ret.reason | Should Match "offline"
		}
	}
	Context 'valid' {
		It 'interface wan miniport ipv6' {
			$ret = Get-NetworkInterface -InterfaceDescription ipv6
			$ret.status | Should match "pass"
			$ret.reason | Should match "Index: \d{1,2}, Disabled: .*WAN Miniport \(IPv6\).*"
		}
	}
}

Describe 'Invoke-PowerSponse' {
	Context 'error' {
		It 'no rule' {
			{ Invoke-PowerSponse } | Should Throw "you have to provide a rule"
		}
		
		It 'offline' {
			{ Invoke-PowerSponse -ComputerName notexistinghost } | Should Throw "you have to provide a rule"
		}

		It 'rule not found' {
			{ Invoke-PowerSponse -RuleFile rulefile-test.xml -ComputerName notexistinghost } | Should throw "rulefile-test.xml not found"
		}

		It 'offline host with invalid rule' {
			Set-Content -Path TestDrive:\rulefile-test.xml -Value "empty rule"
			{ Invoke-PowerSponse -RuleFile TestDrive:\rulefile-test.xml -ComputerName notexistinghost } | Should throw "XML could not be parsed"
		}
	}

	Context 'valid' {
		It 'valid rule file' {
$rule = @"
<PowerSponse>
	<Rule id="12341234-1234-1234-1234-123412341234">
		<name>myrule-check</name>
		<author>userX</author>
		<date>2017-01-14</date>
		<description>Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</description>
		<links>https://swisscom.com/security, https://swisscom.ch/security</links>
		<Action>
			<type>ServiceItem</type>
			<name>my service name</name>
		</Action>
	</Rule>
</PowerSponse>
"@
			Set-Content -Path TestDrive:\rule.xml -Value $rule
			$ret = Invoke-PowerSponse -RuleFile TestDrive:\rule.xml -PrintCommand
			$ret[0] | Should Be "`$val = Disable-Service @DefaultParams -Method WMI -Name `"my service name`""
		}

		It 'valid rule file with two actions' {
$rule = @"
<PowerSponse>
	<Rule id="12341234-1234-1234-1234-123412341234">
		<name>myrule-check</name>
		<author>userX</author>
		<date>2017-01-14</date>
		<description>Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</description>
		<links>https://swisscom.com/security, https://swisscom.ch/security</links>
		<Action>
			<type>ServiceItem</type>
			<name>my service name</name>
		</Action>
		<Action>
			<type>TaskItem</type>
			<searchstring>bad task</searchstring>
		</Action>
	</Rule>
</PowerSponse>
"@
			Set-Content -Path TestDrive:\rule.xml -Value $rule
			$ret = Invoke-PowerSponse -RuleFile TestDrive:\rule.xml -PrintCommand
			$ret[0] | Should Be "`$val = Disable-Service @DefaultParams -Method WMI -Name `"my service name`""
			$ret[1] | Should Be "`$val = Disable-ScheduledTask @DefaultParams -Method external -SearchString `"bad task`""
		}
	}
}

Describe 'Get-PowerSponseRule' {
	Context 'error' {
		It 'no parameter' {
			{ Get-PowerSponseRule } | Should Throw "you have to provide"
		}

		It 'non existing file' {
 			{ Get-PowerSponseRule -RuleFile not-existing.xml } | Should Throw "not-existing.xml not found"
		}

		It 'invalid rule' {
			Set-Content -Path TestDrive:\rulefile-test.xml -Value "empty rule"
			{ Get-PowerSponseRule -RuleFile TestDrive:\rulefile-test.xml } | Should throw "XML could not be parsed"
		}
	}

	Context 'valid' {
		It 'read valid rule file with one rule' {
$rule = @"
<PowerSponse>
	<Rule id="12341234-1234-1234-1234-123412341234">
		<name>myrule-check</name>
		<author>userX</author>
		<date>2017-01-14</date>
		<description>Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</description>
		<links>https://swisscom.com/security, https://swisscom.ch/security</links>
		<Action>
			<type>ServiceItem</type>
			<searchstring>my service name</searchstring>
		</Action>
	</Rule>
</PowerSponse>
"@
			Set-Content -Path TestDrive:\rule.xml -Value $rule
			$ret = Get-PowerSponseRule -RuleFile TestDrive:\rule.xml
			($ret.action | measure).count | should be 1
			$ret.action.type | should match ServiceItem
		}

		It 'read valid file with two rule' {
$rule = @"
<PowerSponse>
	<Rule id="12341234-1234-1234-1234-123412341234">
		<name>myrule-check</name>
		<author>userX</author>
		<date>2017-01-14</date>
		<description>Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</description>
		<links>https://swisscom.com/security, https://swisscom.ch/security</links>
		<Action>
			<type>ServiceItem</type>
			<name>my service name</name>
		</Action>
	</Rule>
	<Rule id="99999999-1234-1234-1234-123412341234">
		<name>second rule</name>
		<author>userX</author>
		<date>2017-01-15</date>
		<description>Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</description>
		<links>https://swisscom.com/security, https://swisscom.ch/security</links>
		<Action>
			<type>TaskItem</type>
			<searchstring>my bad task name</searchstring>
		</Action>
	</Rule>
</PowerSponse>
"@
			Set-Content -Path TestDrive:\rule.xml -Value $rule
			$ret = Get-PowerSponseRule -RuleFile TestDrive:\rule.xml

			($ret[0].action | measure).count | should be 1
			$ret[0].action.type | should match ServiceItem
			$ret[0].name | should match "myrule-check"
			$ret[0].action.name | should match "my service name"

			($ret[1].action | measure).count | should be 1
			$ret[1].action.type | should match TaskItem
			$ret[1].name | should match "second rule"
			$ret[1].action.searchstring | should match "my bad task name"
		}

		It 'read valid JSON rule file with one rule' {
$rule = @"
{
	"PowerSponse": {
		"Rule" : [
			{
				"id" : "12341234-1234-1234-1234-123412341234",
				"name" : "my json rule",
				"author" : "UserX",
				"description" : "Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
				"action" : [
					{
						"type" : "ServiceItem",
						"name" : "my service name"
					}
				]
			}
		]
	}
}
"@
			Set-Content -Path TestDrive:\rule.json -Value $rule
			$ret = Get-PowerSponseRule -method json -RuleFile TestDrive:\rule.json
			($ret.action | measure).count | should be 1
			$ret.action.type | should match ServiceItem
		}

		It 'read valid file with two rule' {
$rule = @"
{
	"PowerSponse": {
		"Rule" : [
			{
				"id" : "12341234-1234-1234-1234-123412341234",
				"name" : "my json rule",
				"author" : "UserX",
				"description" : "Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
				"action" : [
					{
						"type" : "ServiceItem",
						"name" : "my service name"
					}
				]
			},
			{
				"id" : "99999999-1234-1234-1234-123412341234",
				"name" : "my second json rule",
				"author" : "UserZ",
				"description" : "Lectus eu magna vulputate ultrices. Aliquam interdum varius enim. Maecenas at mauris. Sed sed nibh. Nam non turpis. Maecenas fermentum nibh in est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
				"action" : [
					{
						"type" : "TaskItem",
						"searchstring" : "my bad task name"
					}
				]
			}
		]
	}
}
"@
			Set-Content -Path TestDrive:\rule.json -Value $rule
			$ret = Get-PowerSponseRule -Method json -RuleFile TestDrive:\rule.json

			($ret[0].action | measure).count | should be 1
			$ret[0].action.type | should match ServiceItem
			$ret[0].name | should match "my json rule"
			$ret[0].action.name | should match "my service name"

			($ret[1].action | measure).count | should be 1
			$ret[1].action.type | should match TaskItem
			$ret[1].name | should match "my second json rule"
			$ret[1].action.searchstring | should match "my bad task name"
		}
	}
}

Describe 'Get-PowerSponseRepository' {
	Context 'valid' {
		It 'read keys from repository' {
			(Get-PowerSponseRepository).keys | Should Not Be $null
			(Get-PowerSponseRepository).ProcessItem | Should Not Be $null
		}
	}
}

Describe 'Set-PowerSponseRepository' {
	Context 'valid' {
		It 'set new repository' {
			$ret1 = Get-PowerSponseRepository
			$ret1.ProcessItem.DefaultMethod | Should match "wmi"

			$ret1.ProcessItem.DefaultMethod = "external"
			$ret1.ProcessItem.DefaultMethod | Should match "external"

			$ret2 = Get-PowerSponseRepository
			$ret2.ProcessItem.DefaultMethod | Should match "wmi"

			Set-PowerSponseRepository $ret1

			$ret3 = Get-PowerSponseRepository
			$ret3.ProcessItem.DefaultMethod | Should match "external"
		}
	}
}

Describe 'Import-PowerSponseRepository' {

	Context 'valid' {
		It 'set changed repo and then reload repository' {
			Import-PowerSponseRepository

			$ret = Get-PowerSponseRepository
			$ret.ProcessItem.DefaultMethod | Should match "wmi"

			$ret.ProcessItem.DefaultMethod = "external"
			$ret.ProcessItem.DefaultMethod | Should match "external"

			Import-PowerSponseRepository

			$ret = Get-PowerSponseRepository
			$ret.ProcessItem.DefaultMethod | Should match "wmi"
		}
	}
}
