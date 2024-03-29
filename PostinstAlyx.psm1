# -
#   Windows Postinstall Script - Tweaks library
#   (https://github.com/azealyx/windows-postinstall-alyx)
#   Author: Azealyx <itsazealyx@gmail.com>
#   Version: v1.1, 2023-12-04
#
#   Original author: Disassembler <disassembler@dasm.cz>
#   Cloned from: https://github.com/Disassembler0/Win10-Initial-Setup-Script
# -

##########
#region Privacy
##########

# Disable Telemetry Services
# Note: This tweak also disables the possibility to join Windows Insider Program and breaks Microsoft Intune enrollment/deployment, as these feaures require Telemetry data.
# Windows Update control panel may show message "Your device is at risk because it's out of date and missing important security and quality updates. Let's get you back on track so Windows can run more securely. Select this button to get going".
# In such case, enable telemetry, run Windows update and then disable telemetry again.
# See also https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/57 and https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/92
Function DisableTelemetry {
	Write-Output "Disabling Telemetry Services..."
	# Diagnostic Data Level
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
		}
		if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection")) {
			New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
		}
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
		}

		if (Get-WindowsEdition -Online | Where-Object -FilterScript {$_.Edition -like "Enterprise*" -or $_.Edition -eq "Education"}) {
			# Security level
			Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
			Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
			Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
		} else {
			# Required diagnostic data
			Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1
			Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1
			Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 1
		}

		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 1
		Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 1
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 1

		if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack")) {
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1

	# KMS Client Online AVS Validation
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Name "NoGenTicket" -Type DWord -Value 1

	# Customer Experience Improvement Program
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\SQMClient\Windows")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\SQMClient\Windows" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWord -Value 0

		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\AppV\CEIP")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\AppV\CEIP" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\AppV\CEIP" -Name "CEIPEnable" -Type DWord -Value 0

	# Application Telemetry
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppCompat")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" -Force | Out-Null
		}	
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Type DWord -Value 0
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -Type DWord -Value 1

	# Handwriting personalization data sharing
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -Type DWord -Value 1

	# Improve inking and typing recognition
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\TextInput")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -Type DWord -Value 0

	# Scheduled Tasks
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" -ErrorAction SilentlyContinue | Out-Null

	# Office 2016 / 2019
	Disable-ScheduledTask -TaskName "Microsoft\Office\Office ClickToRun Service Monitor" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentFallBack2016" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentLogOn2016" -ErrorAction SilentlyContinue | Out-Null

	# PowerShell 7
	[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', '1', [System.EnvironmentVariableTarget]::Machine)

	# .NET SDK
	[System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', [System.EnvironmentVariableTarget]::Machine)

	# Azure SQL Edge
	[System.Environment]::SetEnvironmentVariable('MSSQL_TELEMETRY_ENABLED', 'FALSE', [System.EnvironmentVariableTarget]::Machine)
}

# Enable Telemetry Services
Function EnableTelemetry {
	Write-Output "Enabling Telemetry Services..."
	# DiagnosticDataLevel
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
		}
		if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection")) {
			New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
		}
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
		}

		Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue

		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 3
		Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 3
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 3

		if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack")) {
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 3

	# KMS Client Online AVS Validation
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform" -Name "NoGenTicket" -ErrorAction SilentlyContinue

	# Customer Experience Improvement Program
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\AppV\CEIP" -Name "CEIPEnable" -ErrorAction SilentlyContinue

	# Application Telemetry
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -ErrorAction SilentlyContinue

	# Handwriting personalization data sharing
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\TabletPC" -Name "PreventHandwritingDataSharing" -ErrorAction SilentlyContinue

	# Improve inking and typing recognition
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\TextInput" -Name "AllowLinguisticDataCollection" -ErrorAction SilentlyContinue

	# Scheduled Tasks
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" -ErrorAction SilentlyContinue | Out-Null

	# Office 2016 / 2019
	Enable-ScheduledTask -TaskName "Microsoft\Office\Office ClickToRun Service Monitor" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentFallBack2016" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Office\OfficeTelemetryAgentLogOn2016" -ErrorAction SilentlyContinue | Out-Null

	# PowerShell 7
	[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', $null, [System.EnvironmentVariableTarget]::Machine)

	# .NET SDK
	[System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', $null, [System.EnvironmentVariableTarget]::Machine)

	# Azure SQL Edge
	[System.Environment]::SetEnvironmentVariable('MSSQL_TELEMETRY_ENABLED', $null, [System.EnvironmentVariableTarget]::Machine)
}


# Disable Feedback
Function DisableFeedback {
	Write-Output "Disabling Feedback..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Siuf\Rules")) {
		New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1

	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}

# Enable Feedback
Function EnableFeedback {
	Write-Output "Enabling Feedback..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}


# Stop and disable Connected User Experiences and Telemetry (previously named Diagnostics Tracking Service)
Function DisableDiagTrack {
	Write-Output "Stopping and disabling Connected User Experiences and Telemetry Service..."
	Stop-Service "DiagTrack" -WarningAction SilentlyContinue
	Set-Service "DiagTrack" -StartupType Disabled
	Get-NetFirewallRule -Group DiagTrack | Set-NetFirewallRule -Enabled False -Action Block
}

# Enable and start Connected User Experiences and Telemetry (previously named Diagnostics Tracking Service)
Function EnableDiagTrack {
	Write-Output "Enabling and starting Connected User Experiences and Telemetry Service ..."
	Set-Service "DiagTrack" -StartupType Automatic
	Start-Service "DiagTrack" -WarningAction SilentlyContinue
	Get-NetFirewallRule -Group DiagTrack | Set-NetFirewallRule -Enabled True -Action Allow
}


# Stop and disable Diagnostics Hub Standard Collector Service
Function DisableDiagHub {
	Write-Output "Stopping and disabling Diagnostics Hub Standard Collector Service..."
	Stop-Service "diagnosticshub.standardcollector.service" -WarningAction SilentlyContinue
	Set-Service "diagnosticshub.standardcollector.service" -StartupType Disabled
}

# Enable and start Diagnostics Hub Standard Collector Service
Function EnableDiagHub {
	Write-Output "Enabling Diagnostics Hub Standard Collector Service..."
	Set-Service "diagnosticshub.standardcollector.service" -StartupType Manual
	Start-Service "diagnosticshub.standardcollector.service" -WarningAction SilentlyContinue
}


# Stop and disable Device Management Wireless Application Protocol (WAP) Push Service
# Note: This service is needed for Microsoft Intune interoperability
Function DisableWAPPush {
	Write-Output "Stopping and disabling Device Management WAP Push Service..."
	Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
	Set-Service "dmwappushservice" -StartupType Disabled
}

# Enable and start Device Management Wireless Application Protocol (WAP) Push Service
Function EnableWAPPush {
	Write-Output "Enabling and starting Device Management WAP Push Service..."
	Set-Service "dmwappushservice" -StartupType Automatic
	Start-Service "dmwappushservice" -WarningAction SilentlyContinue
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Services\dmwappushservice")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Services\dmwappushservice" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\dmwappushservice" -Name "DelayedAutoStart" -Type DWord -Value 1
}


# Disable Advertising ID
Function DisableAdvertisingID {
	Write-Output "Disabling Advertising ID..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 1
}

# Enable Advertising ID
Function EnableAdvertisingID {
	Write-Output "Enabling Advertising ID..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AdvertisingInfo" -Name "Enabled" -ErrorAction SilentlyContinue
}


# Disable setting 'Let websites provide locally relevant content by accessing my language list'
Function DisableWebLangList {
	Write-Output "Disabling Website Access to Language List..."
	if (!(Test-Path "HKCU:\Control Panel\International\User Profile")) {
		New-Item -Path "HKCU:\Control Panel\International\User Profile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -Type DWord -Value 1
}

# Enable setting 'Let websites provide locally relevant content by accessing my language list'
Function EnableWebLangList {
	Write-Output "Enabling Website Access to Language List..."
	Remove-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" -Name "HttpAcceptLanguageOptOut" -ErrorAction SilentlyContinue
}


# Disable App Launch Tracking
Function DisableAppLaunchTrack {
	Write-Output "Disabling App Launch Tracking..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 0
}

# Enable App Launch Tracking
Function EnableAppLaunchTrack {
	Write-Output "Enabling App Launch Tracking..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Type DWord -Value 1
}


# Disable Tailored Experiences
Function DisableTailoredExperiences {
	Write-Output "Disabling Tailored Experiences..."
	if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0
}

# Enable Tailored Experiences
Function EnableTailoredExperiences {
	Write-Output "Enabling Tailored Experiences..."
	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -ErrorAction SilentlyContinue

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 1
}


# Disable Error reporting
Function DisableErrorReporting {
	Write-Output "Disabling Error reporting..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1

	Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" -ErrorAction SilentlyContinue | Out-Null

	Stop-Service "WerSvc" -WarningAction SilentlyContinue
	Set-Service "WerSvc" -StartupType Disabled
}

# Enable Error reporting
Function EnableErrorReporting {
	Write-Output "Enabling Error reporting..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" -ErrorAction SilentlyContinue | Out-Null

	Set-Service "WerSvc" -StartupType Manual
	Start-Service "WerSvc" -WarningAction SilentlyContinue
}


# Disable Activity History feed in Task View
# Note: The checkbox "Store my activity history on this device" ("Let Windows collect my activities from this PC" on older versions) remains checked even when the function is disabled
Function DisableActivityHistory {
	Write-Output "Disabling Activity History..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\System")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
}

# Enable Activity History feed in Task View
Function EnableActivityHistory {
	Write-Output "Enabling Activity History..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -ErrorAction SilentlyContinue
}

##########
#endregion Privacy
##########



##########
#region UWP App Permissions
##########
# Universal Windows Platform (UWP) is an API for common application and device controls unified for all devices capable of running Windows 10.
# UWP applications are running sandboxed and the user can control devices and capabilities available to them.

# Disable location feature and scripting for the location feature
Function DisablePermsLocation {
	Write-Output "Disabling location services..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -Type DWord -Value 1

	Stop-Service "lfsvc" -WarningAction SilentlyContinue # Geolocation Service
	Set-Service "lfsvc" -StartupType Disabled
}

# Enable location feature and scripting for the location feature
Function EnablePermsLocation {
	Write-Output "Enabling location services..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -ErrorAction SilentlyContinue

	Set-Service "lfsvc" -StartupType Manual
	Start-Service "lfsvc" -WarningAction SilentlyContinue # Geolocation Service
}


# Disable access to camera
# Note: This disables access using standard Windows API. Direct access to device will still be allowed.
Function DisablePermsCamera {
	Write-Output "Disabling access to camera..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCamera" -Type DWord -Value 2
}

# Enable access to camera
Function EnablePermsCamera {
	Write-Output "Enabling access to camera..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCamera" -ErrorAction SilentlyContinue
}


# Disable access to microphone
# Note: This disables access using standard Windows API. Direct access to device will still be allowed.
Function DisablePermsMicrophone {
	Write-Output "Disabling access to microphone..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMicrophone" -Type DWord -Value 2
}

# Enable access to microphone
Function EnablePermsMicrophone {
	Write-Output "Enabling access to microphone..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMicrophone" -ErrorAction SilentlyContinue
}


# Disable access to voice activation from UWP apps
Function DisablePermsVoiceActivation {
	Write-Output "Disabling access to voice activation from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsActivateWithVoice" -Type DWord -Value 2
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsActivateWithVoiceAboveLock" -Type DWord -Value 2
}

# Enable access to voice activation from UWP apps
Function EnablePermsVoiceActivation {
	Write-Output "Enabling access to voice activation from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsActivateWithVoice" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsActivateWithVoiceAboveLock" -ErrorAction SilentlyContinue
}


# Disable access to notifications from UWP apps
Function DisablePermsNotifications {
	Write-Output "Disabling access to notifications from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessNotifications" -Type DWord -Value 2
}

# Enable access to notifications from UWP apps
Function EnablePermsNotifications {
	Write-Output "Enabling access to notifications from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessNotifications" -ErrorAction SilentlyContinue
}


# Disable access to account info from UWP apps
Function DisablePermsAccountInfo {
	Write-Output "Disabling access to account info from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessAccountInfo" -Type DWord -Value 2
}

# Enable access to account info from UWP apps
Function EnablePermsAccountInfo {
	Write-Output "Enabling access to account info from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessAccountInfo" -ErrorAction SilentlyContinue
}


# Disable access to contacts from UWP apps
Function DisablePermsContacts {
	Write-Output "Disabling access to contacts from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessContacts" -Type DWord -Value 2
}

# Enable access to contacts from UWP apps
Function EnablePermsContacts {
	Write-Output "Enabling access to contacts from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessContacts" -ErrorAction SilentlyContinue
}


# Disable access to calendar from UWP apps
Function DisablePermsCalendar {
	Write-Output "Disabling access to calendar from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCalendar" -Type DWord -Value 2
}

# Enable access to calendar from UWP apps
Function EnablePermsCalendar {
	Write-Output "Enabling access to calendar from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCalendar" -ErrorAction SilentlyContinue
}


# Disable access to phone calls from UWP apps
Function DisablePermsPhoneCalls {
	Write-Output "Disabling access to phone calls from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessPhone" -Type DWord -Value 2
}

# Enable access to phone calls from UWP apps
Function EnablePermsPhoneCalls {
	Write-Output "Enabling access to phone calls from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessPhone" -ErrorAction SilentlyContinue
}


# Disable access to call history from UWP apps
Function DisablePermsCallHistory {
	Write-Output "Disabling access to call history from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCallHistory" -Type DWord -Value 2
}

# Enable access to call history from UWP apps
Function EnablePermsCallHistory {
	Write-Output "Enabling access to call history from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessCallHistory" -ErrorAction SilentlyContinue
}


# Disable access to email from UWP apps
Function DisablePermsEmail {
	Write-Output "Disabling access to email from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessEmail" -Type DWord -Value 2
}

# Enable access to email from UWP apps
Function EnablePermsEmail {
	Write-Output "Enabling access to email from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessEmail" -ErrorAction SilentlyContinue
}


# Disable access to tasks from UWP apps
Function DisablePermsTasks {
	Write-Output "Disabling access to tasks from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessTasks" -Type DWord -Value 2
}

# Enable access to tasks from UWP apps
Function EnablePermsTasks {
	Write-Output "Enabling access to tasks from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessTasks" -ErrorAction SilentlyContinue
}


# Disable access to messaging (SMS, MMS) from UWP apps
Function DisablePermsMessaging {
	Write-Output "Disabling access to messaging from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMessaging" -Type DWord -Value 2
}

# Enable access to messaging from UWP apps
Function EnablePermsMessaging {
	Write-Output "Enabling access to messaging from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessMessaging" -ErrorAction SilentlyContinue
}


# Disable access to radios (e.g. Bluetooth) from UWP apps
Function DisablePermsRadios {
	Write-Output "Disabling access to radios from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessRadios" -Type DWord -Value 2
}

# Enable access to radios from UWP apps
Function EnablePermsRadios {
	Write-Output "Enabling access to radios from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsAccessRadios" -ErrorAction SilentlyContinue
}


# Disable access to other devices (unpaired, beacons, TVs etc.) from UWP apps
Function DisablePermsOtherDevices {
	Write-Output "Disabling access to other devices from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsSyncWithDevices" -Type DWord -Value 2
}

# Enable access to other devices from UWP apps
Function EnablePermsOtherDevices {
	Write-Output "Enabling access to other devices from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsSyncWithDevices" -ErrorAction SilentlyContinue
}


# Disable UWP apps background access - ie. if UWP apps can download data or update themselves when they aren't used
# Until 1809, Cortana and ShellExperienceHost need to be explicitly excluded as their inclusion breaks start menu search and toast notifications respectively.
Function DisablePermsBackgroundApps {
	Write-Output "Disabling UWP apps background access..."
	if ([System.Environment]::OSVersion.Version.Build -ge 17763) {
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -Type DWord -Value 2
	} else {
		Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Exclude "Microsoft.Windows.Cortana*", "Microsoft.Windows.ShellExperienceHost*" | ForEach-Object {
			Set-ItemProperty -Path $_.PsPath -Name "Disabled" -Type DWord -Value 1
			Set-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -Type DWord -Value 1
		}
	}
}

# Enable UWP apps background access
Function EnablePermsBackgroundApps {
	Write-Output "Enabling UWP apps background access..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -ErrorAction SilentlyContinue
	Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" | ForEach-Object {
		Remove-ItemProperty -Path $_.PsPath -Name "Disabled" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -ErrorAction SilentlyContinue
	}
}


# Disable access to diagnostic information from UWP apps
Function DisablePermsDiagInfo {
	Write-Output "Disabling access to diagnostic information from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsGetDiagnosticInfo" -Type DWord -Value 2
}

# Enable access to diagnostic information from UWP apps
Function EnablePermsDiagInfo {
	Write-Output "Enabling access to diagnostic information from UWP apps..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsGetDiagnosticInfo" -ErrorAction SilentlyContinue
}


# Disable access to libraries and file system from UWP apps
Function DisablePermsFileSystem {
	Write-Output "Disabling access to libraries and file system from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Name "Value" -Type String -Value "Deny"

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Name "Value" -Type String -Value "Deny"

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Name "Value" -Type String -Value "Deny"

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Name "Value" -Type String -Value "Deny"
}

# Enable access to libraries and file system from UWP apps
Function EnablePermsFileSystem {
	Write-Output "Enabling access to libraries and file system from UWP apps..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Name "Value" -Type String -Value "Allow"

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Name "Value" -Type String -Value "Allow"

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Name "Value" -Type String -Value "Allow"

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Name "Value" -Type String -Value "Allow"
}


# Disable UWP apps swap file
# This disables creation and use of swapfile.sys and frees 256 MB of disk space. Swapfile.sys is used only by UWP apps. The tweak has no effect on the real swap in pagefile.sys.
Function DisableUWPSwapFile {
	Write-Output "Disabling UWP apps swap file..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management" -Name "SwapfileControl" -Type Dword -Value 0
}

# Enable UWP apps swap file
Function EnableUWPSwapFile {
	Write-Output "Enabling UWP apps swap file..."
	Remove-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management" -Name "SwapfileControl" -ErrorAction SilentlyContinue
}

##########
#endregion UWP App Permissions
##########



##########
#region Updates & Security
##########

# Disable Windows Update automatic downloads
Function DisableUpdateAutoDownload {
	Write-Output "Disabling Windows Update automatic downloads..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type DWord -Value 2
}

# Enable Windows Update automatic downloads
Function EnableUpdateAutoDownload {
	Write-Output "Enabling Windows Update automatic downloads..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -ErrorAction SilentlyContinue
}


# Enable receiving updates for other Microsoft products via Windows Update
Function EnableUpdateMSProducts {
	Write-Output "Enabling updates for other Microsoft products..."
	(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") | Out-Null
}

# Disable receiving updates for other Microsoft products via Windows Update
Function DisableUpdateMSProducts {
	Write-Output "Disabling updates for other Microsoft products..."
	if ((New-Object -ComObject Microsoft.Update.ServiceManager).Services | Where-Object { $_.ServiceID -eq "7971f918-a847-4430-9279-4a52d1efe18d"}) {
		(New-Object -ComObject Microsoft.Update.ServiceManager).RemoveService("7971f918-a847-4430-9279-4a52d1efe18d") | Out-Null
	}
}


# Disable automatic restart after Windows Update installation
# The tweak is slightly experimental, as it registers a dummy debugger for MusNotification.exe
# which blocks the restart prompt executable from running, thus never schedulling the restart
Function DisableUpdateRestart {
	Write-Output "Disabling Windows Update automatic restart..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Name "Debugger" -Type String -Value "cmd.exe"
}

# Enable automatic restart after Windows Update installation
Function EnableUpdateRestart {
	Write-Output "Enabling Windows Update automatic restart..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\MusNotification.exe" -Name "Debugger" -ErrorAction SilentlyContinue
}


# Disable Automatic Restart Sign-on - Applicable since 1903
# See https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/winlogon-automatic-restart-sign-on--arso-
Function DisableAutoRestartSignOn {
	Write-Output "Disabling Automatic Restart Sign-on..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -Type DWord -Value 1

	$SID = (Get-CimInstance -ClassName Win32_UserAccount | Where-Object -FilterScript {$_.Name -eq $env:USERNAME}).SID

	if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$SID")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$SID" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$SID" -Name "OptOut" -Type DWord -Value 1
}

# Enable Automatic Restart Sign-on - Applicable since 1903
Function EnableAutoRestartSignOn {
	Write-Output "Enabling Automatic Restart Sign-on..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableAutomaticRestartSignOn" -ErrorAction SilentlyContinue

	$SID = (Get-CimInstance -ClassName Win32_UserAccount | Where-Object -FilterScript {$_.Name -eq $env:USERNAME}).SID
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\$SID" -Name "OptOut" -ErrorAction SilentlyContinue
}



# Disable offering of Malicious Software Removal Tool through Windows Update
Function DisableUpdateMSRT {
	Write-Output "Disabling Malicious Software Removal Tool offering..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\MRT")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\MRT" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
}

# Enable offering of Malicious Software Removal Tool through Windows Update
Function EnableUpdateMSRT {
	Write-Output "Enabling Malicious Software Removal Tool offering..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -ErrorAction SilentlyContinue
}


# Disable offering of drivers through Windows Update
# Note: This doesn't work properly if you use a driver intended for another hardware model. E.g. Intel I219-V on WinServer works only with I219-LM driver.
# Therefore Windows update will repeatedly try and fail to install I219-V driver indefinitely even if you use the tweak.
Function DisableUpdateDriver {
	Write-Output "Disabling driver offering through Windows Update..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Device Metadata")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Device Metadata" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DriverSearching")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DriverSearching" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DriverSearching" -Name "SearchOrderConfig" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Type DWord -Value 1
}

# Enable offering of drivers through Windows Update
Function EnableUpdateDriver {
	Write-Output "Enabling driver offering through Windows Update..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DriverSearching" -Name "SearchOrderConfig" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
}


# Disable Windows Update P2P delivery optimization
Function SetP2PUpdateDisable {
	Write-Output "Disabling Windows Update delivery optimization..."
	if ([System.Environment]::OSVersion.Version.Build -eq 10240) {
		# Method used in 1507
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
	} elseif ([System.Environment]::OSVersion.Version.Build -le 14393) {
		# Method used in 1511 and 1607
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 1
	} else {
		# Method used since 1703
		Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
	}

	Set-ItemProperty -Path "Registry::HKEY_USERS\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" -Name "DownloadMode" -Type DWord -Value 0
}

# Restrict Windows Update P2P delivery optimization to computers in local network - Default since 1703
Function SetP2PUpdateLocal {
	Write-Output "Setting Windows Update delivery optimization to Local..."
	Set-ItemProperty -Path "Registry::HKEY_USERS\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" -Name "DownloadMode" -Type DWord -Value 1

	if ([System.Environment]::OSVersion.Version.Build -eq 10240) {
		# Method used in 1507
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
	} elseif ([System.Environment]::OSVersion.Version.Build -le 14393) {
		# Method used in 1511 and 1607
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 1
	} else {
		# Method used since 1703
		Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
	}
}

# Unrestrict Windows Update P2P delivery optimization to both local networks and internet - Default in 1507 - 1607
Function SetP2PUpdateInternet {
	Write-Output "Unrestricting Windows Update delivery optimization to Internet..."
	Set-ItemProperty -Path "Registry::HKEY_USERS\S-1-5-20\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" -Name "DownloadMode" -Type DWord -Value 1

	if ([System.Environment]::OSVersion.Version.Build -eq 10240) {
		# Method used in 1507
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 3
	} elseif ([System.Environment]::OSVersion.Version.Build -le 14393) {
		# Method used in 1511 and 1607
		Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -ErrorAction SilentlyContinue
	} else {
		# Method used since 1703
		if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization")) {
			New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 3
	}
}


# Disable Windows Defender
Function DisableDefender {
	Write-Output "Disabling Windows Defender..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows Defender")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1

	if ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
	} elseif ([System.Environment]::OSVersion.Version.Build -ge 15063) {
		Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
	}
}

# Enable Windows Defender
Function EnableDefender {
	Write-Output "Enabling Windows Defender..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Force | Out-Null
	}

	if ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
	} elseif ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 17134) {
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%ProgramFiles%\Windows Defender\MSASCuiL.exe"
	} elseif ([System.Environment]::OSVersion.Version.Build -ge 17763) {
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%windir%\system32\SecurityHealthSystray.exe"
	}
}


# Disable Windows Defender Cloud
Function DisableDefenderCloud {
	Write-Output "Disabling Windows Defender Cloud..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Type DWord -Value 2
}

# Enable Windows Defender Cloud
Function EnableDefenderCloud {
	Write-Output "Enabling Windows Defender Cloud..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -ErrorAction SilentlyContinue
}


# Enable Controlled Folder Access (Defender Exploit Guard feature) - Applicable since 1709, requires Windows Defender to be enabled
Function EnableCtrldFolderAccess {
	Write-Output "Enabling Controlled Folder Access..."
	Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
}

# Disable Controlled Folder Access (Defender Exploit Guard feature) - Applicable since 1709, requires Windows Defender to be enabled
Function DisableCtrldFolderAccess {
	Write-Output "Disabling Controlled Folder Access..."
	Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue
}


# Disable Require Sign-in on Wakeup
Function DisableWakeUpSignIn {
	Write-Output "Disabling Require Sign-in on Wakeup..."
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0 | Out-Null
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0 | Out-Null
}

# Enable Require Sign-in on Wakeup
Function EnableWakeUpSignIn {
	Write-Output "Enabling Require Sign-in on Wakeup..."
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 1 | Out-Null
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 1 | Out-Null
}


# Hide Account Protection warning in Defender about not using a Microsoft account
Function HideAccountProtectionWarn {
	Write-Output "Hiding Account Protection warning..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows Security Health\State")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows Security Health\State" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows Security Health\State" -Name "AccountProtection_MicrosoftAccount_Disconnected" -Type DWord -Value 1
}

# Show Account Protection warning in Defender
Function ShowAccountProtectionWarn {
	Write-Output "Showing Account Protection warning..."
	Remove-ItemProperty "HKCU:\Software\Microsoft\Windows Security Health\State" -Name "AccountProtection_MicrosoftAccount_Disconnected" -ErrorAction SilentlyContinue
}


# Lower UAC level (disabling it completely would break apps)
Function SetUACLow {
	Write-Output "Lowering UAC level..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
}

# Raise UAC level
Function SetUACHigh {
	Write-Output "Raising UAC level..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1
}


# Disable blocking of downloaded files (i.e. storing zone information - no need to do File\Properties\Unblock)
Function DisableDownloadBlocking {
	Write-Output "Disabling blocking of downloaded files..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -Name "SaveZoneInformation" -Type DWord -Value 1
}

# Enable blocking of downloaded files
Function EnableDownloadBlocking {
	Write-Output "Enabling blocking of downloaded files..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -Name "SaveZoneInformation" -ErrorAction SilentlyContinue
}


# Disable Windows Script Host (execution of *.vbs scripts and alike)
Function DisableScriptHost {
	Write-Output "Disabling Windows Script Host..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows Script Host\Settings")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows Script Host\Settings" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0
}

# Enable Windows Script Host
Function EnableScriptHost {
	Write-Output "Enabling Windows Script Host..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows Script Host\Settings" -Name "Enabled" -ErrorAction SilentlyContinue
}


# Enable strong cryptography for old versions of .NET Framework (4.6 and newer have strong crypto enabled by default)
# https://docs.microsoft.com/en-us/dotnet/framework/network-programming/tls#schusestrongcrypto
Function EnableDotNetStrongCrypto {
	Write-output "Enabling .NET strong cryptography..."
	if (!(Test-Path "HKLM:\Software\Microsoft\.NETFramework\v4.0.30319")) {
		New-Item -Path "HKLM:\Software\Microsoft\.NETFramework\v4.0.30319" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\.NETFramework\v4.0.30319")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
}

# Disable strong cryptography for old versions of .NET Framework
Function DisableDotNetStrongCrypto {
	Write-output "Disabling .NET strong cryptography..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
}


# Enable Meltdown (CVE-2017-5754) compatibility flag - Required for January and February 2018 Windows updates
# This flag is normally automatically enabled by compatible antivirus software (such as Windows Defender).
# Use the tweak only if you have confirmed that your AV is compatible but unable to set the flag automatically or if you don't use any AV at all.
# As of March 2018, the compatibility check has been lifted for security updates.
# See https://support.microsoft.com/en-us/help/4072699/windows-security-updates-and-antivirus-software for details
Function EnableMeltdownCompatFlag {
	Write-Output "Enabling Meltdown (CVE-2017-5754) compatibility flag..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\QualityCompat")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\QualityCompat" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 0
}

# Disable Meltdown (CVE-2017-5754) compatibility flag
Function DisableMeltdownCompatFlag {
	Write-Output "Disabling Meltdown (CVE-2017-5754) compatibility flag..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -ErrorAction SilentlyContinue
}


# Disable Firewall
Function DisableFirewall {
	Write-Output "Disabling Firewall..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsFirewall\StandardProfile")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsFirewall\StandardProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -Type DWord -Value 0
}

# Enable Firewall
Function EnableFirewall {
	Write-Output "Enabling Firewall..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
}


# Disable SmartScreen Filter
Function DisableSmartScreen {
	Write-Output "Disabling SmartScreen Filter..."
	auditpol /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:disable /failure:disable | Out-Null

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\System")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 0
}

# Enable SmartScreen Filter
Function EnableSmartScreen {
	Write-Output "Enabling SmartScreen Filter..."
	auditpol /set /subcategory:"{0CCE922B-69AE-11D9-BED3-505054503030}" /success:enable /failure:enable | Out-Null
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -ErrorAction SilentlyContinue
}


# Hide Smart Screen filter warning in Defender
Function HideSmartScreenWarn {
	Write-Output "Hiding Smart Screen filter warning..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows Security Health\State")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows Security Health\State" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows Security Health\State" -Name "AppAndBrowser_EdgeSmartScreenOff" -Type DWord -Value 0
}

# Show Smart Screen filter warning in Defender
Function ShowSmartScreenWarn {
	Write-Output "Showing Smart Screen filter warning..."
	Remove-ItemProperty "HKCU:\Software\Microsoft\Windows Security Health\State" -Name "AppAndBrowser_EdgeSmartScreenOff" -ErrorAction SilentlyContinue
}


# Enable Windows Defender Application Guard - Applicable since 1709 Enterprise and 1803 Pro. Not applicable to Server
# Not supported on VMs and VDI environment. Check requirements on https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-guard/reqs-wd-app-guard
Function EnableDefenderAppGuard {
	Write-Output "Enabling Windows Defender Application Guard..."
	Enable-WindowsOptionalFeature -online -FeatureName "Windows-Defender-ApplicationGuard" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Disable Windows Defender Application Guard - Applicable since 1709 Enterprise and 1803 Pro. Not applicable to Server
Function DisableDefenderAppGuard {
	Write-Output "Disabling Windows Defender Application Guard..."
	Disable-WindowsOptionalFeature -online -FeatureName "Windows-Defender-ApplicationGuard" -NoRestart -WarningAction SilentlyContinue | Out-Null
}


# Set Data Execution Prevention (DEP) policy to OptOut - Turn on DEP for all 32-bit applications except manually excluded. 64-bit applications have DEP always on.
Function SetDEPOptOut {
	Write-Output "Setting Data Execution Prevention (DEP) policy to OptOut..."
	bcdedit /set `{current`} nx OptOut | Out-Null
}

# Set Data Execution Prevention (DEP) policy to OptIn - Turn on DEP only for essential 32-bit Windows executables and manually included applications. 64-bit applications have DEP always on.
Function SetDEPOptIn {
	Write-Output "Setting Data Execution Prevention (DEP) policy to OptIn..."
	bcdedit /set `{current`} nx OptIn | Out-Null
}


# Enable Core Isolation Memory Integrity - Part of Windows Defender System Guard virtualization-based security - Applicable since 1803
# Warning: This may cause old applications and drivers to crash or even cause BSOD
# Problems were confirmed with old video drivers (Intel HD Graphics for 2nd gen., Radeon HD 6850), and old antivirus software (Kaspersky Endpoint Security 10.2, 11.2)
Function EnableCIMemoryIntegrity {
	Write-Output "Enabling Core Isolation Memory Integrity..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type DWord -Value 1
}

# Disable Core Isolation Memory Integrity - Applicable since 1803
Function DisableCIMemoryIntegrity {
	Write-Output "Disabling Core Isolation Memory Integrity..."
	Remove-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction SilentlyContinue
}


# Enable sharing mapped drives between users
Function EnableSharingMappedDrives {
	Write-Output "Enabling sharing mapped drives between users..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -Type DWord -Value 1
}

# Disable sharing mapped drives between users
Function DisableSharingMappedDrives {
	Write-Output "Disabling sharing mapped drives between users..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -ErrorAction SilentlyContinue
}


# Disable implicit administrative shares
Function DisableAdminShares {
	Write-Output "Disabling implicit administrative shares..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Type DWord -Value 0
}

# Enable implicit administrative shares
Function EnableAdminShares {
	Write-Output "Enabling implicit administrative shares..."
	Remove-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -ErrorAction SilentlyContinue
}


# Disable nightly wake-up for Automatic Maintenance and Windows Updates
Function DisableMaintenanceWakeUp {
	Write-Output "Disabling nightly wake-up for Automatic Maintenance..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "WakeUp" -Type DWord -Value 0
}

# Enable nightly wake-up for Automatic Maintenance and Windows Updates
Function EnableMaintenanceWakeUp {
	Write-Output "Enabling nightly wake-up for Automatic Maintenance..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "WakeUp" -ErrorAction SilentlyContinue
}


# Enable F8 boot menu options
Function EnableF8BootMenu {
	Write-Output "Enabling F8 boot menu options..."
	bcdedit /set `{current`} BootMenuPolicy Legacy | Out-Null
}

# Disable F8 boot menu options
Function DisableF8BootMenu {
	Write-Output "Disabling F8 boot menu options..."
	bcdedit /set `{current`} BootMenuPolicy Standard | Out-Null
}


# Disable automatic recovery mode during boot
# This causes boot process to always ignore startup errors and attempt to boot normally
# It is still possible to interrupt the boot and enter recovery mode manually. In order to disable even that, apply also DisableRecoveryAndReset tweak
Function DisableBootRecovery {
	Write-Output "Disabling automatic recovery mode during boot..."
	bcdedit /set `{current`} BootStatusPolicy IgnoreAllFailures | Out-Null
}

# Enable automatic entering recovery mode during boot
# This allows the boot process to automatically enter recovery mode when it detects startup errors (default behavior)
Function EnableBootRecovery {
	Write-Output "Enabling automatic recovery mode during boot..."
	bcdedit /deletevalue `{current`} BootStatusPolicy | Out-Null
}


# Disable System Recovery and Factory reset
# Warning: This tweak completely removes the option to enter the system recovery during boot and the possibility to perform a factory reset
Function DisableRecoveryAndReset {
	Write-Output "Disabling System Recovery and Factory reset..."
	reagentc /disable 2>&1 | Out-Null
}

# Enable System Recovery and Factory reset
Function EnableRecoveryAndReset {
	Write-Output "Enabling System Recovery and Factory reset..."
	reagentc /enable 2>&1 | Out-Null
}

##########
#endregion Updates & Security
##########



##########
#region Network & Internet
##########

# Stop and disable Home Groups services - Not applicable since 1803. Not applicable to Server
Function DisableHomeGroups {
	Write-Output "Stopping and disabling Home Groups services..."
	if (Get-Service "HomeGroupListener" -ErrorAction SilentlyContinue) {
		Stop-Service "HomeGroupListener" -WarningAction SilentlyContinue
		Set-Service "HomeGroupListener" -StartupType Disabled
	}
	if (Get-Service "HomeGroupProvider" -ErrorAction SilentlyContinue) {
		Stop-Service "HomeGroupProvider" -WarningAction SilentlyContinue
		Set-Service "HomeGroupProvider" -StartupType Disabled
	}
}

# Enable and start Home Groups services - Not applicable since 1803. Not applicable to Server
Function EnableHomeGroups {
	Write-Output "Starting and enabling Home Groups services..."
	Set-Service "HomeGroupListener" -StartupType Manual
	Set-Service "HomeGroupProvider" -StartupType Manual
	Start-Service "HomeGroupProvider" -WarningAction SilentlyContinue
}


# Set current network profile to private (allow file sharing, device discovery, etc.)
Function SetCurrentNetworkPrivate {
	Write-Output "Setting current network profile to private..."
	Set-NetConnectionProfile -NetworkCategory Private
}

# Set current network profile to public (deny file sharing, device discovery, etc.)
Function SetCurrentNetworkPublic {
	Write-Output "Setting current network profile to public..."
	Set-NetConnectionProfile -NetworkCategory Public
}


# Set unknown networks profile to public (deny file sharing, device discovery, etc.)
Function SetUnknownNetworksPublic {
	Write-Output "Setting unknown networks profile to public..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -ErrorAction SilentlyContinue
}

# Set unknown networks profile to private (allow file sharing, device discovery, etc.)
Function SetUnknownNetworksPrivate {
	Write-Output "Setting unknown networks profile to private..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -Type DWord -Value 1
}


# Disable Wi-Fi Sense
Function DisableWiFiSense {
	Write-Output "Disabling Wi-Fi Sense..."
	if (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
		New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config")) {
		New-Item -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type DWord -Value 0
}

# Enable Wi-Fi Sense
Function EnableWiFiSense {
	Write-Output "Enabling Wi-Fi Sense..."
	if (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 1

	if (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
		New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -ErrorAction SilentlyContinue
}


# Disable automatic installation of network devices
Function DisableNetDevicesAutoInst {
	Write-Output "Disabling automatic installation of network devices..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -Type DWord -Value 0
}

# Enable automatic installation of network devices
Function EnableNetDevicesAutoInst {
	Write-Output "Enabling automatic installation of network devices..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -ErrorAction SilentlyContinue
}


# Disable Network Connectivity Status Indicator active test
# Note: This may reduce the ability of OS and other components to determine internet access, however protects against a specific type of zero-click attack.
# See https://github.com/Disassembler0/Win10-Initial-Setup-Script/pull/111 for details
Function DisableNCSIProbe {
	Write-Output "Disabling Network Connectivity Status Indicator (NCSI) active test..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" -Name "NoActiveProbe" -Type DWord -Value 1
}

# Enable Network Connectivity Status Indicator active test
Function EnableNCSIProbe {
	Write-Output "Enabling Network Connectivity Status Indicator (NCSI) active test..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator" -Name "NoActiveProbe" -ErrorAction SilentlyContinue
}


# Disable Internet Connection Sharing (e.g. mobile hotspot)
Function DisableConnectionSharing {
	Write-Output "Disabling Internet Connection Sharing..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Network Connections")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Network Connections" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Network Connections" -Name "NC_ShowSharedAccessUI" -Type DWord -Value 0
}

# Enable Internet Connection Sharing (e.g. mobile hotspot)
Function EnableConnectionSharing {
	Write-Output "Enabling Internet Connection Sharing..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Network Connections" -Name "NC_ShowSharedAccessUI" -ErrorAction SilentlyContinue
}


# Disable Client for Microsoft Networks for all installed network interfaces
Function DisableMSNetClient {
	Write-Output "Disabling Client for Microsoft Networks..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_msclient"
}

# Enable Client for Microsoft Networks for all installed network interfaces
Function EnableMSNetClient {
	Write-Output "Enabling Client for Microsoft Networks..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_msclient"
}


# Disable obsolete SMB 1.0 protocol - Disabled by default since 1709
Function DisableSMB1 {
	Write-Output "Disabling SMB 1.0 protocol..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
}

# Enable obsolete SMB 1.0 protocol - Disabled by default since 1709
Function EnableSMB1 {
	Write-Output "Enabling SMB 1.0 protocol..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force
}


# Disable SMB Server - Completely disables file and printer sharing, but leaves the system able to connect to another SMB server as a client
# Note: Do not run this if you plan to use Docker and Shared Drives (as it uses SMB internally), see https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/216
Function DisableSMBServer {
	Write-Output "Disabling SMB Server..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
	Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_server"
}

# Enable SMB Server
Function EnableSMBServer {
	Write-Output "Enabling SMB Server..."
	Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_server"
}


# Disable Quality of Service (QoS) packet scheduler for all installed network interfaces
Function DisableQoS {
	Write-Output "Disabling Quality of Service (QoS) packet scheduler..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_pacer"
}

# Enable Quality of Service (QoS) packet scheduler for all installed network interfaces
Function EnableQoS {
	Write-Output "Enabling Quality of Service (QoS) packet scheduler..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_pacer"
}


# Disable Link-Local Multicast Name Resolution (LLMNR) protocol
Function DisableLLMNR {
	Write-Output "Disabling Link-Local Multicast Name Resolution (LLMNR)..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Type DWord -Value 0
}

# Enable Link-Local Multicast Name Resolution (LLMNR) protocol
Function EnableLLMNR {
	Write-Output "Enabling Link-Local Multicast Name Resolution (LLMNR)..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -ErrorAction SilentlyContinue
}


# Disable IPv4 stack for all installed network interfaces
Function DisableIPv4 {
	Write-Output "Disabling IPv4 stack..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip"
}

# Enable IPv4 stack for all installed network interfaces
Function EnableIPv4 {
	Write-Output "Enabling IPv4 stack..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip"
}


# Disable IPv6 stack for all installed network interfaces
Function DisableIPv6 {
	Write-Output "Disabling IPv6 stack..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip6"
}

# Enable IPv6 stack for all installed network interfaces
Function EnableIPv6 {
	Write-Output "Enabling IPv6 stack..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip6"
}


# Disable NetBIOS over TCP/IP on all currently installed network interfaces
Function DisableNetBIOS {
	Write-Output "Disabling NetBIOS over TCP/IP..."
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\services\NetBT\Parameters\Interfaces\Tcpip*" -Name "NetbiosOptions" -Type DWord -Value 2
}

# Enable NetBIOS over TCP/IP on all currently installed network interfaces
Function EnableNetBIOS {
	Write-Output "Enabling NetBIOS over TCP/IP..."
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\services\NetBT\Parameters\Interfaces\Tcpip*" -Name "NetbiosOptions" -Type DWord -Value 0
}


# Disable Local-Link Discovery Protocol (LLDP) for all installed network interfaces
Function DisableLLDP {
	Write-Output "Disabling Local-Link Discovery Protocol (LLDP)..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_lldp"
}

# Enable Local-Link Discovery Protocol (LLDP) for all installed network interfaces
Function EnableLLDP {
	Write-Output "Enabling Local-Link Discovery Protocol (LLDP)..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_lldp"
}

# Disable Local-Link Topology Discovery (LLTD) for all installed network interfaces
Function DisableLLTD {
	Write-Output "Disabling Local-Link Topology Discovery (LLTD)..."
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_lltdio"
	Disable-NetAdapterBinding -Name "*" -ComponentID "ms_rspndr"
}

# Enable Local-Link Topology Discovery (LLTD) for all installed network interfaces
Function EnableLLTD {
	Write-Output "Enabling Local-Link Topology Discovery (LLTD)..."
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_lltdio"
	Enable-NetAdapterBinding -Name "*" -ComponentID "ms_rspndr"
}

##########
#endregion Network & Internet
##########



##########
#region Personalization
##########

# Set Light Mode for System
Function SetSystemLightMode {
	Write-Output "Setting Light Mode for System..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 0
}

# Set Dark Mode for System
Function SetSystemDarkMode {
	Write-Output "Setting Dark Mode for System..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0
}


# Set Light Mode for Applications
Function SetAppsLightMode {
	Write-Output "Setting Light Mode for Applications..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 1
}

# Set Dark Mode for Applications
Function SetAppsDarkMode {
	Write-Output "Setting Dark Mode for Applications..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0
}


# Enable transparency effects
Function DisableTransparency {
	Write-Output "Disabling transparency effects..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0
}

# Enable transparency effects
Function EnableTransparency {
	Write-Output "Enabling transparency effects..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 1
}


# Enable window title bar color according to prevalent background color
Function EnableTitleBarColor {
	Write-Output "Enabling window title bar accent color..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\DWM")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\DWM" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 1
}

# Disable window title bar accent color
Function DisableTitleBarColor {
	Write-Output "Disabling window title bar accent color..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\DWM")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\DWM" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Type DWord -Value 0
}


# Enable taskbar accent color according to prevalent background color
Function EnableTaskbarColor {
	$val = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme"
	if($val.SystemUsesLightTheme -ne 1) {
		Write-Output "Enabling taskbar accent color..."
		if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 1
	}
}

# Disable taskbar accent color
Function DisableTaskbarColor {
	Write-Output "Disabling taskbar accent color..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Type DWord -Value 0
}


# Adjusts visual effects based on standard preferences
Function SetVisualFXStandard {
	Write-Output "Adjusts visual effects based on standard preferences..."
	# Visual Effects - Custom
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3

	# [x] Smooth-scroll list boxes
	# [ ] Slide open combo boxes
	# [ ] Fade or slide menus into view
	# [ ] Show shadows under mouse pointer
	# [ ] Fade or slide ToolTips into view
	# [ ] Fade out menu items after clicking
	# [x] Show shadows under windows
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](152,18,7,128,18,0,0,0))

	# [x] Animate windows when minimizing and maximizing
	if (!(Test-Path "HKCU:\Control Panel\Desktop\WindowMetrics")) {
		New-Item -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 1

	# [x] Animations in the taskbar
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 1

	# [x] Enable Peek
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\DWM")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\DWM" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1

	# [ ] Save taskbar thumbnail previews
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Type DWord -Value 0

	# [x] Show thumbnails instead of icons
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
	}
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "DisableThumbnails" -ErrorAction SilentlyContinue

	# [x] Show translucent slection rectangle
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1

	# [x] Show window contents while dragging
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1

	# [x] Smooth edges of screen fonts
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Type String -Value 2

	# [x] Use drop shadows for icon labels on the desktop
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 1

	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 400

	if (!(Test-Path "HKCU:\Control Panel\Keyboard")) {
		New-Item -Path "HKCU:\Control Panel\Keyboard" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1
}

# Adjusts visual effects for appearance
Function SetVisualFXAppearance {
	Write-Output "Adjusting visual effects for appearance..."
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 400
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](158,30,7,128,18,0,0,0))

	if (!(Test-Path "HKCU:\Control Panel\Desktop\WindowMetrics")) {
		New-Item -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 1

	if (!(Test-Path "HKCU:\Control Panel\Keyboard")) {
		New-Item -Path "HKCU:\Control Panel\Keyboard" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 1

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\DWM")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\DWM" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1
}

# Adjusts visual effects for performance - Disables animations, transparency etc. but leaves font smoothing and miniatures enabled
Function SetVisualFXPerformance {
	Write-Output "Adjusting visual effects for performance..."
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 0
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144,18,3,128,16,0,0,0))

	if (!(Test-Path "HKCU:\Control Panel\Desktop\WindowMetrics")) {
		New-Item -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 0

	if (!(Test-Path "HKCU:\Control Panel\Keyboard")) {
		New-Item -Path "HKCU:\Control Panel\Keyboard" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 0

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\DWM")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\DWM" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0
}


# Disable Lock screen Blur - Applicable since 1903
Function DisableLockScreenBlur {
	Write-Output "Disabling Lock screen Blur..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\System")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DisableAcrylicBackgroundOnLogon" -Type DWord -Value 1
}

# Enable Lock screen Blur - Applicable since 1903
Function EnableLockScreenBlur {
	Write-Output "Enabling Lock screen Blur..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DisableAcrylicBackgroundOnLogon" -ErrorAction SilentlyContinue
}


# Hide network options from Lock Screen
Function HideNetworkFromLockScreen {
	Write-Output "Hiding network options from Lock Screen..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\System")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DontDisplayNetworkSelectionUI" -Type DWord -Value 1
}

# Show network options on lock screen
Function ShowNetworkOnLockScreen {
	Write-Output "Showing network options on Lock Screen..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "DontDisplayNetworkSelectionUI" -ErrorAction SilentlyContinue
}


# Hide shutdown options from Lock Screen
Function HideShutdownFromLockScreen {
	Write-Output "Hiding shutdown options from Lock Screen..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Type DWord -Value 0
}

# Show shutdown options on lock screen
Function ShowShutdownOnLockScreen {
	Write-Output "Showing shutdown options on Lock Screen..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Type DWord -Value 1
}


# Enable verbose startup/shutdown status messages
Function EnableVerboseStatus {
	Write-Output "Enabling verbose startup/shutdown status messages..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -Type DWord -Value 1
	} else {
		Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -ErrorAction SilentlyContinue
	}
}

# Disable verbose startup/shutdown status messages
Function DisableVerboseStatus {
	Write-Output "Disabling verbose startup/shutdown status messages..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -ErrorAction SilentlyContinue
	} else {
		if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
			New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -Type DWord -Value 0
	}
}


# Disable "Hi!" First Logon Animation (it will be replaced by "Preparing Windows" message)
Function DisableFirstLogonAnimation {
	Write-Output "Disabling First Logon Animation..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableFirstLogonAnimation" -Type DWord -Value 0
}

# Enable "Hi!" First Logon Animation
Function EnableFirstLogonAnimation {
	Write-Output "Enabling First Logon Animation..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableFirstLogonAnimation" -ErrorAction SilentlyContinue
}


# Disable changing sound scheme
Function DisableChangingSoundScheme {
	Write-Output "Disabling changing sound scheme..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoChangingSoundScheme" -Type DWord -Value 1
}

# Enable changing sound scheme
Function EnableChangingSoundScheme {
	Write-Output "Enabling changing sound scheme..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoChangingSoundScheme" -ErrorAction SilentlyContinue
}


# Set sound scheme to No Sounds
Function SetSoundSchemeNone {
	Write-Output "Setting sound scheme to No Sounds..."
	$SoundScheme = ".None"
	Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps\*\*" | ForEach-Object {
		# If scheme keys do not exist in an event, create empty ones (similar behavior to Sound control panel).
		if (!(Test-Path "$($_.PsPath)\$($SoundScheme)")) {
			New-Item -Path "$($_.PsPath)\$($SoundScheme)" | Out-Null
		}
		if (!(Test-Path "$($_.PsPath)\.Current")) {
			New-Item -Path "$($_.PsPath)\.Current" | Out-Null
		}
		# Get a regular string from any possible kind of value, i.e. resolve REG_EXPAND_SZ, copy REG_SZ or empty from non-existing.
		$Data = (Get-ItemProperty -Path "$($_.PsPath)\$($SoundScheme)" -Name "(Default)" -ErrorAction SilentlyContinue)."(Default)"
		# Replace any kind of value with a regular string (similar behavior to Sound control panel).
		Set-ItemProperty -Path "$($_.PsPath)\$($SoundScheme)" -Name "(Default)" -Type String -Value $Data
		# Copy data from source scheme to current.
		Set-ItemProperty -Path "$($_.PsPath)\.Current" -Name "(Default)" -Type String -Value $Data
	}

	if (!(Test-Path "HKCU:\AppEvents\Schemes")) {
		New-Item -Path "HKCU:\AppEvents\Schemes" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Type String -Value $SoundScheme
}

# Set sound scheme to Windows Default
Function SetSoundSchemeDefault {
	Write-Output "Setting sound scheme to Windows Default..."
	$SoundScheme = ".Default"
	Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps\*\*" | ForEach-Object {
		# If scheme keys do not exist in an event, create empty ones (similar behavior to Sound control panel).
		if (!(Test-Path "$($_.PsPath)\$($SoundScheme)")) {
			New-Item -Path "$($_.PsPath)\$($SoundScheme)" | Out-Null
		}
		if (!(Test-Path "$($_.PsPath)\.Current")) {
			New-Item -Path "$($_.PsPath)\.Current" | Out-Null
		}
		# Get a regular string from any possible kind of value, i.e. resolve REG_EXPAND_SZ, copy REG_SZ or empty from non-existing.
		$Data = (Get-ItemProperty -Path "$($_.PsPath)\$($SoundScheme)" -Name "(Default)" -ErrorAction SilentlyContinue)."(Default)"
		# Replace any kind of value with a regular string (similar behavior to Sound control panel).
		Set-ItemProperty -Path "$($_.PsPath)\$($SoundScheme)" -Name "(Default)" -Type String -Value $Data
		# Copy data from source scheme to current.
		Set-ItemProperty -Path "$($_.PsPath)\.Current" -Name "(Default)" -Type String -Value $Data
	}

	if (!(Test-Path "HKCU:\AppEvents\Schemes")) {
		New-Item -Path "HKCU:\AppEvents\Schemes" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name "(Default)" -Type String -Value $SoundScheme
}


# Disable playing Windows Startup sound
Function DisableStartupSound {
	Write-Output "Disabling Windows Startup sound..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 1
}

# Enable playing Windows Startup sound
Function EnableStartupSound {
	Write-Output "Enabling Windows Startup sound..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" -Name "DisableStartupSound" -Type DWord -Value 0
}


# Hide 'Recently added' list from the Start Menu
Function HideRecentlyAddedApps {
	Write-Output "Hiding 'Recently added' list from the Start Menu..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Type DWord -Value 1
}

# Show 'Recently added' list in the Start Menu
Function ShowRecentlyAddedApps {
	Write-Output "Showing 'Recently added' list in the Start Menu..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -ErrorAction SilentlyContinue
}


# Hide 'Most used' apps list from the Start Menu - Applicable until 1703 (hidden by default since then)
Function HideMostUsedApps {
	Write-Output "Hiding 'Most used' apps list from the Start Menu..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMFUprogramsList" -Type DWord -Value 1
}

# Show 'Most used' apps list in the Start Menu - Applicable until 1703 (GPO broken since then)
Function ShowMostUsedApps {
	Write-Output "Showing 'Most used' apps list in the Start Menu..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMFUprogramsList" -ErrorAction SilentlyContinue
}


# Disable Application suggestions and automatic installation
Function DisableAppSuggestions {
	Write-Output "Disabling Application suggestions..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314559Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsInkWorkspace")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsInkWorkspace" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowSuggestedAppsInWindowsInkWorkspace" -Type DWord -Value 0

	# Empty placeholder tile collection in registry cache and restart Start Menu process to reload the cache
	if ([System.Environment]::OSVersion.Version.Build -ge 17134) {
		$key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
		Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $key.Data[0..15]
		Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
	}

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0
}

# Enable Application suggestions and automatic installation
Function EnableAppSuggestions {
	Write-Output "Enabling Application suggestions..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 1

	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314559Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowSuggestedAppsInWindowsInkWorkspace" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -ErrorAction SilentlyContinue
}


# Hide browsing history from the Start Menu
Function HideBrowsingHistory {
	Write-Output "Hiding browsing history from the Start Menu..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_RecoPersonalizedSites" -Type DWord -Value 0
}

# Show 'Browsing history' from the Start Menu
Function ShowBrowsingHistory {
	Write-Output "Showing browsing history from the Start Menu..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_RecoPersonalizedSites" -ErrorAction SilentlyContinue
}


# Disable Search Highlights
Function DisableSearchHighlights {
	Write-Output "Disabling Search Highlights..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Name "ShowDynamicContent" -Type DWord -Value 0

	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Type DWord -Value 0
}

# Enable Search Highlights
Function EnableSearchHighlights {
	Write-Output "Enabling Search Highlights..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Name "ShowDynamicContent" -Type DWord -Value 1

	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Type DWord -Value 1
}


# Set Start Layout to Show More Pins
Function SetStartLayoutPins {
	Write-Output "Setting Start Layout to Show More Pins..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Type DWord -Value 1
}

# Set Start Layout to Default setting
Function SetStartLayoutDefault {
	Write-Output "Setting Start Layout to Default setting..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Type DWord -Value 0
}

# Set Start Layout to Show More Recommendations
Function SetStartLayoutRecs {
	Write-Output "Setting Start Layout to Show More Recommendations..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Type DWord -Value 2
}


# Disable Search Highlights
Function DisableSearchHighlights {
	Write-Output "Disabling Search Highlights..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Name "ShowDynamicContent" -Type DWord -Value 0

	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Type DWord -Value 0
}

# Enable Search Highlights
Function EnableSearchHighlights {
	Write-Output "Enabling Search Highlights..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds\DSB" -Name "ShowDynamicContent" -Type DWord -Value 1

	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Type DWord -Value 1
}


# Disable Web Search in Start Menu
Function DisableWebSearch {
	Write-Output "Disabling Bing Search in Start Menu..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1


	if (!(Test-Path -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Type DWord -Value 1
}

# Enable Web Search in Start Menu
Function EnableWebSearch {
	Write-Output "Enabling Bing Search in Start Menu..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -ErrorAction SilentlyContinue

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -ErrorAction SilentlyContinue

	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -ErrorAction SilentlyContinue
}


# Set Taskbar Alignment to Left
Function SetTaskbarAlignLeft {
	Write-Output "Setting Taskbar Alignment to Left..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0
}

# Set Taskbar Alignment to Center
Function SetTaskbarAlignCenter {
	Write-Output "Setting Taskbar Alignment to Center..."
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 1
}


# Show large icons in taskbar
Function ShowLargeTaskbarIcons {
	Write-Output "Showing large icons in taskbar..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -ErrorAction SilentlyContinue
}

# Show small icons in taskbar
Function ShowSmallTaskbarIcons {
	Write-Output "Showing small icons in taskbar..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type DWord -Value 1
}


# Set PowerShell instead of Command prompt in Start Button context menu (Win+X) - Default since 1703
Function SetWinXMenuPowerShell {
	Write-Output "Setting PowerShell instead of Command prompt in WinX menu..."
	if ([System.Environment]::OSVersion.Version.Build -le 14393) {
		if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DontUsePowerShellOnWinX" -Type DWord -Value 0
	} else {
		Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DontUsePowerShellOnWinX" -ErrorAction SilentlyContinue
	}
}

# Set Command prompt instead of PowerShell in Start Button context menu (Win+X) - Default in 1507 - 1607
Function SetWinXMenuCmd {
	Write-Output "Setting Command prompt instead of PowerShell in WinX menu..."
	if ([System.Environment]::OSVersion.Version.Build -le 14393) {
		Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DontUsePowerShellOnWinX" -ErrorAction SilentlyContinue
	} else {
		if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
		}
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DontUsePowerShellOnWinX" -Type DWord -Value 1
	}
}


# Set taskbar buttons to always combine and hide labels
Function SetTaskbarCombineAlways {
	Write-Output "Setting taskbar buttons to always combine, hide labels..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarGlomLevel" -ErrorAction SilentlyContinue
}

# Set taskbar buttons to show labels and combine when taskbar is full
Function SetTaskbarCombineWhenFull {
	Write-Output "Setting taskbar buttons to combine when taskbar is full..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarGlomLevel" -Type DWord -Value 1
}

# Set taskbar buttons to show labels and never combine
Function SetTaskbarCombineNever {
	Write-Output "Setting taskbar buttons to never combine..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 2
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MMTaskbarGlomLevel" -Type DWord -Value 2
}


# Hide Taskbar Search icon / box
Function HideTaskbarSearch {
	Write-Output "Hiding Taskbar Search icon / box..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
}

# Show Taskbar Search icon
Function ShowTaskbarSearchIcon {
	Write-Output "Showing Taskbar Search icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
}

# Show Taskbar Search box
Function ShowTaskbarSearchBox {
	Write-Output "Showing Taskbar Search box..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 2
}


# Hide Taskbar Copilot icon
Function HideTaskbarCopilot {
	Write-Output "Hiding Taskbar Copilot icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 0
}

# Show Taskbar Copilot icon
Function ShowTaskbarCopilot {
	Write-Output "Showing Taskbar Copilot icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 1
}


# Hide Taskbar Chat icon
Function HideTaskbarChat {
	Write-Output "Hiding Taskbar Chat icon..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Chat")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Chat" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -Type DWord -Value 3

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0
}

# Show Taskbar Chat icon
Function ShowTaskbarChat {
	Write-Output "Showing Taskbar Chat icon..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Chat" -Name "ChatIcon" -ErrorAction SilentlyContinue

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 1
}


# Hide News and Interests on the taskbar
Function HideWidgets {
	Write-Output "Hiding Widgets on the taskbar..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Type DWord -Value 0

	# Windows 11 Widgets
	if (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests")) {
		New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 0

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Dsh")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Dsh" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0
}

# Show Widgets on the taskbar
Function ShowWidgets {
	Write-Output "Showing Widgets on the taskbar..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -ErrorAction SilentlyContinue

	# Windows 11 Widgets
	if (!(Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests")) {
		New-Item -Path "HKLM:\Software\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" -Name "value" -Type DWord -Value 1

	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -ErrorAction SilentlyContinue
}


# Hide Task View button
Function HideTaskView {
	Write-Output "Hiding Task View button..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
}

# Show Task View button
Function ShowTaskView {
	Write-Output "Showing Task View button..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -ErrorAction SilentlyContinue
}


# Show all tray icons
Function ShowTrayIcons {
	Write-Output "Showing all tray icons..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoAutoTrayNotify" -Type DWord -Value 1
}

# Hide tray icons as needed
Function HideTrayIcons {
	Write-Output "Hiding tray icons..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoAutoTrayNotify" -ErrorAction SilentlyContinue
}


# Show seconds in taskbar
Function ShowSecondsInTaskbar {
	Write-Output "Showing seconds in taskbar..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Type DWord -Value 1
}

# Hide seconds from taskbar
Function HideSecondsFromTaskbar {
	Write-Output "Hiding seconds from taskbar..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -ErrorAction SilentlyContinue
}


# Hide Taskbar People icon
Function HideTaskbarPeopleIcon {
	Write-Output "Hiding People icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
}

# Show Taskbar People icon
Function ShowTaskbarPeopleIcon {
	Write-Output "Showing People icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 1
}


# Hide Windows Ink Workspace icon
Function HideInkWorkspaceIcon {
	Write-Output "Hiding Windows Ink Workspace icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name "PenWorkspaceButtonDesiredVisibility" -Type DWord -Value 0
}

# Show Windows Ink Workspace icon
Function ShowInkWorkspaceIcon {
	Write-Output "Showing Windows Ink Workspace icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name "PenWorkspaceButtonDesiredVisibility" -Type DWord -Value 1
}


# Hide Touch Keyboard icon
Function HideTouchKeyboardIcon {
	Write-Output "Hiding Touch Keyboard icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\TabletTip\1.7")) {
		New-Item -Path "HKCU:\Software\Microsoft\TabletTip\1.7" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "TipbandDesiredVisibility" -Type DWord -Value 0
}

# Show Touch Keyboard icon
Function ShowTouchKeyboardIcon {
	Write-Output "Showing Touch Keyboard icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\TabletTip\1.7")) {
		New-Item -Path "HKCU:\Software\Microsoft\TabletTip\1.7" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "TipbandDesiredVisibility" -Type DWord -Value 1
}


# Hide Bluetooth tray icon
Function HideBluetoothTrayIcon {
	Write-Output "Hiding Bluetooth tray icon..."
	if (!(Test-Path "HKCU:\Control Panel\Bluetooth")) {
		New-Item -Path "HKCU:\Control Panel\Bluetooth" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Bluetooth" -Name "Notification Area Icon" -Type DWord -Value 0
}

# Show Bluetooth tray icon
Function ShowBluetoothTrayIcon {
	Write-Output "Showing Bluetooth tray icon..."
	if (!(Test-Path "HKCU:\Control Panel\Bluetooth")) {
		New-Item -Path "HKCU:\Control Panel\Bluetooth" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Bluetooth" -Name "Notification Area Icon" -Type DWord -Value 1
}


# Hide Windows Defender SysTray icon
Function HideDefenderTrayIcon {
	Write-Output "Hiding Windows Defender SysTray icon..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Systray")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Systray" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Systray" -Name "HideSystray" -Type DWord -Value 1

	if ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
	} elseif ([System.Environment]::OSVersion.Version.Build -ge 15063) {
		Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
	}
}

# Show Windows Defender SysTray icon
Function ShowDefenderTrayIcon {
	Write-Output "Showing Windows Defender SysTray icon..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Systray" -Name "HideSystray" -ErrorAction SilentlyContinue

	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Force | Out-Null
	}
	if ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
	} elseif ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 17134) {
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%ProgramFiles%\Windows Defender\MSASCuiL.exe"
	} elseif ([System.Environment]::OSVersion.Version.Build -ge 17763) {
		Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "%windir%\system32\SecurityHealthSystray.exe"
	}
}


# Hide Meet Now tray icon
Function HideMeetNowTrayIcon {
	Write-Output "Hiding Meet Now tray icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type DWord -Value 1

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" | Out-Null
	}
	$MeetNowSettings = Get-ItemPropertyValue -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3 -Name Settings -ErrorAction Ignore
	$MeetNowSettings[9] = 128
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -Type Binary -Value $MeetNowSettings
}

# Show Meet Now tray icon
Function ShowMeetNowTrayIcon {
	Write-Output "Showing Meet Now tray icon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Type DWord -Value 0

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" | Out-Null
	}
	$MeetNowSettings = Get-ItemPropertyValue -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3 -Name Settings -ErrorAction Ignore
	$MeetNowSettings[9] = 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -Type Binary -Value $MeetNowSettings
}

##########
#endregion Personalization
##########



##########
#region Windows Explorer
##########

# Show all icons on desktop
Function ShowDesktopIcons {
	Write-Output "Showing all icons on desktop..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 0
}

# Hide all icons from desktop
Function HideDesktopIcons {
	Write-Output "Hiding all icons from desktop..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 1
}


# Set JPEG wallpaper to standard quality
Function SetWallpaperQualitySD {
	Write-Output "Setting JPEG wallpaper to standard quality..."
	Remove-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name JPEGImportQuality -Force -ErrorAction SilentlyContinue
}

# Set JPEG wallpaper to high quality
Function SetWallpaperQualityHD {
	Write-Output "Setting JPEG wallpaper to high quality..."
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "JPEGImportQuality" -Type DWord -Value 100
}


# Hide shortcut icon arrow
Function HideShortcutArrow {
	Write-Output "Hiding shortcut icon arrow..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Type String -Value "%SystemRoot%\System32\imageres.dll,-1015"
}

# Show shortcut icon arrow
Function ShowShortcutArrow {
	Write-Output "Showing shortcut icon arrow..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -ErrorAction SilentlyContinue
}


# Disable adding '- shortcut' to shortcut name
Function DisableShortcutInName {
	Write-Output "Disabling adding '- shortcut' to shortcut name..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "link" -Type Binary -Value ([byte[]](0,0,0,0))

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" -Name "ShortcutNameTemplate" -Type String -Value "%s.lnk" -ErrorAction SilentlyContinue
}

# Enable adding '- shortcut' to shortcut name
Function EnableShortcutInName {
	Write-Output "Enabling adding '- shortcut' to shortcut name..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "link" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" -Name "ShortcutNameTemplate" -ErrorAction SilentlyContinue
}


# Show This PC shortcut on desktop
Function ShowThisPCOnDesktop {
	Write-Output "Showing This PC shortcut on desktop..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
}

# Hide This PC shortcut from desktop
Function HideThisPCFromDesktop {
	Write-Output "Hiding This PC shortcut from desktop..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
}


# Show User Folder shortcut on desktop
Function ShowUserFolderOnDesktop {
	Write-Output "Showing User Folder shortcut on desktop..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
}

# Hide User Folder shortcut from desktop
Function HideUserFolderFromDesktop {
	Write-Output "Hiding User Folder shortcut from desktop..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
}


# Hide Recycle Bin shortcut from desktop
Function HideRecycleBinFromDesktop {
	Write-Output "Hiding Recycle Bin shortcut from desktop..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Type DWord -Value 1
}

# Show Recycle Bin shortcut on desktop
Function ShowRecycleBinOnDesktop {
	Write-Output "Showing Recycle Bin shortcut on desktop..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -ErrorAction SilentlyContinue
}


# Show Control panel shortcut on desktop
Function ShowControlPanelOnDesktop {
	Write-Output "Showing Control panel shortcut on desktop..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type DWord -Value 0
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Type DWord -Value 0
}

# Hide Control panel shortcut from desktop
Function HideControlPanelFromDesktop {
	Write-Output "Hiding Control panel shortcut from desktop..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -ErrorAction SilentlyContinue
}


# Show Network shortcut on desktop
Function ShowNetworkOnDesktop {
	Write-Output "Showing Network shortcut on desktop..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" )) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"  -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Type DWord -Value 0

	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" )) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Type DWord -Value 0
}

# Hide Network shortcut from desktop
Function HideNetworkFromDesktop {
	Write-Output "Hiding Network shortcut from desktop..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -ErrorAction SilentlyContinue
}


# Show Windows build number and Windows edition (Home/Pro/Enterprise) from bottom right of desktop
Function ShowBuildNumberOnDesktop {
	Write-Output "Showing Windows build number on desktop..."
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "PaintDesktopVersion" -Type DWord -Value 1
}

# Remove Windows build number and Windows edition (Home/Pro/Enterprise) from bottom right of desktop
Function HideBuildNumberFromDesktop {
	Write-Output "Hiding Windows build number from desktop..."
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "PaintDesktopVersion" -Type DWord -Value 0
}


# Hide Desktop icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideDesktopFromThisPC {
	Write-Output "Hiding Desktop icon from This PC..."
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -Recurse -ErrorAction SilentlyContinue
}

# Show Desktop icon in This PC
Function ShowDesktopInThisPC {
	Write-Output "Showing Desktop icon in This PC..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" | Out-Null
	}
}


# Hide Documents icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideDocumentsFromThisPC {
	Write-Output "Hiding Documents icon from This PC..."
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -Recurse -ErrorAction SilentlyContinue
}

# Show Documents icon in This PC
Function ShowDocumentsInThisPC {
	Write-Output "Showing Documents icon in This PC..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" | Out-Null
	}
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" | Out-Null
	}
}


# Hide Downloads icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideDownloadsFromThisPC {
	Write-Output "Hiding Downloads icon from This PC..."
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -Recurse -ErrorAction SilentlyContinue
}

# Show Downloads icon in This PC
Function ShowDownloadsInThisPC {
	Write-Output "Showing Downloads icon in This PC..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" | Out-Null
	}
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" | Out-Null
	}
}


# Hide Music icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideMusicFromThisPC {
	Write-Output "Hiding Music icon from This PC..."
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -Recurse -ErrorAction SilentlyContinue
}

# Show Music icon in This PC
Function ShowMusicInThisPC {
	Write-Output "Showing Music icon in This PC..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" | Out-Null
	}
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" | Out-Null
	}
}


# Hide Pictures icon from This PC - The icon remains in personal folders and open/save dialogs
Function HidePicturesFromThisPC {
	Write-Output "Hiding Pictures icon from This PC..."
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -Recurse -ErrorAction SilentlyContinue
}

# Show Pictures icon in This PC
Function ShowPicturesInThisPC {
	Write-Output "Showing Pictures icon in This PC..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" | Out-Null
	}
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" | Out-Null
	}
}


# Hide Videos icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideVideosFromThisPC {
	Write-Output "Hiding Videos icon from This PC..."
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -Recurse -ErrorAction SilentlyContinue
}

# Show Videos icon in This PC
Function ShowVideosInThisPC {
	Write-Output "Showing Videos icon in This PC..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" | Out-Null
	}
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" | Out-Null
	}
}


# Hide Desktop icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideDesktopFromExplorer {
	Write-Output "Hiding Desktop icon from Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Desktop icon in Explorer namespace
Function ShowDesktopInExplorer {
	Write-Output "Showing Desktop icon in Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}


# Hide Documents icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideDocumentsFromExplorer {
	Write-Output "Hiding Documents icon from Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Documents icon in Explorer namespace
Function ShowDocumentsInExplorer {
	Write-Output "Showing Documents icon in Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}


# Hide Downloads icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideDownloadsFromExplorer {
	Write-Output "Hiding Downloads icon from Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Downloads icon in Explorer namespace
Function ShowDownloadsInExplorer {
	Write-Output "Showing Downloads icon in Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}


# Hide Music icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideMusicFromExplorer {
	Write-Output "Hiding Music icon from Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Music icon in Explorer namespace
Function ShowMusicInExplorer {
	Write-Output "Showing Music icon in Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}


# Hide Pictures icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HidePicturesFromExplorer {
	Write-Output "Hiding Pictures icon from Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Pictures icon in Explorer namespace
Function ShowPicturesInExplorer {
	Write-Output "Showing Pictures icon in Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}


# Hide Videos icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideVideosFromExplorer {
	Write-Output "Hiding Videos icon from Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Videos icon in Explorer namespace
Function ShowVideosInExplorer {
	Write-Output "Showing Videos icon in Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"

	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}


# Hide Network icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideNetworkFromExplorer {
	Write-Output "Hiding Network icon from Explorer namespace..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Type DWord -Value 1
}

# Show Network icon in Explorer namespace
Function ShowNetworkInExplorer {
	Write-Output "Showing Network icon in Explorer namespace..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -Name "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -ErrorAction SilentlyContinue
}


# Set Windows 11 context menu to legacy
Function SetContextMenuLegacy {
	Write-Output "Setting Windows context menu to legacy..."
	if (!(Test-Path -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}")) {
		New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force | Out-Null
	}
	if (!(Test-Path -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32")) {
		New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Type String -Value "" -Force
}

# Set Windows 11 context menu to modern
Function SetContextMenuModern {
	Write-Output "Setting Windows context menu to modern..."
	if (!(Test-Path -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}")) {
		New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force | Out-Null
	}
	Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -ErrorAction SilentlyContinue
}


# Hide 'Edit with Paint 3D' context menu item
Function HideEditWithPaint3DMenu {
	Write-Output "Hiding 'Edit with Paint 3D' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\SystemFileAssociations\.bmp\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\SystemFileAssociations\.gif\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\SystemFileAssociations\.jpe\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\SystemFileAssociations\.jpeg\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\SystemFileAssociations\.jpg\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\SystemFileAssociations\.png\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\SystemFileAssociations\.tif\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\SystemFileAssociations\.tiff\Shell\3D Edit" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.bmp\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.gif\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.jpe\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.jpeg\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.jpg\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.png\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.tif\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
	Set-ItemProperty -Path "HKCR:\SystemFileAssociations\.tiff\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -Type String -Value ""
}

# Show 'Edit with Paint 3D' context menu item
Function ShowEditWithPaint3DMenu {
	Write-Output "Showing 'Edit with Paint 3D' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.bmp\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.gif\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.jpe\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.jpeg\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.jpg\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.png\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.tif\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKCR:\SystemFileAssociations\.tiff\Shell\3D Edit" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
}


# Hide 'Print' context menu item for batch files (.bat, .cmd)
Function HidePrintCMDMenu {
	Write-Output "Hiding 'Print' context menu item for batch files (.bat, .cmd)..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\batfile\shell\print" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\batfile\shell\print" -Name "ProgrammaticAccessOnly" -Type String -Value ""

	New-Item -Path "HKCR:\cmdfile\shell\print" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\cmdfile\shell\print" -Name "ProgrammaticAccessOnly" -Type String -Value ""
}

# Show 'Print' context menu item for batch files (.bat, .cmd)
Function ShowPrintCMDMenu {
	Write-Output "Showing 'Print' context menu item for batch files (.bat, .cmd)..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-ItemProperty -Path "HKCR:\batfile\shell\print" -Name ProgrammaticAccessOnly -Force -ErrorAction Ignore
	Remove-ItemProperty -Path "HKCR:\cmdfile\shell\print" -Name ProgrammaticAccessOnly -Force -ErrorAction Ignore
}


# Hide 'Share' context menu item. Applicable since 1709
Function HideShareMenu {
	Write-Output "Hiding 'Share' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -LiteralPath "HKCR:\*\shellex\ContextMenuHandlers\ModernSharing" -ErrorAction SilentlyContinue
}

# Show 'Share' context menu item. Applicable since 1709
Function ShowShareMenu {
	Write-Output "Showing 'Share' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\*\shellex\ContextMenuHandlers\ModernSharing" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -LiteralPath "HKCR:\*\shellex\ContextMenuHandlers\ModernSharing" -Name "(Default)" -Type String -Value "{e2bf9676-5f8f-435c-97eb-11607a5bedf7}"
}


# Hide 'Give access to' (until 1703 'Share With') context menu item.
Function HideGiveAccessToMenu {
	Write-Output "Hiding 'Give access to' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -LiteralPath "HKCR:\*\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\Directory\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\Drive\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue
}

# Show 'Give access to' (until 1703 'Share With') context menu item.
Function ShowGiveAccessToMenu {
	Write-Output "Showing 'Give access to' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\*\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -LiteralPath "HKCR:\*\shellex\ContextMenuHandlers\Sharing" -Name "(Default)" -Type String -Value "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}"
	New-Item -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\Directory\Background\shellex\ContextMenuHandlers\Sharing" -Name "(Default)" -Type String -Value "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}"
	New-Item -Path "HKCR:\Directory\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\Directory\shellex\ContextMenuHandlers\Sharing" -Name "(Default)" -Type String -Value "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}"
	New-Item -Path "HKCR:\Drive\shellex\ContextMenuHandlers\Sharing" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\Drive\shellex\ContextMenuHandlers\Sharing" -Name "(Default)" -Type String -Value "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}"
}


# Hide 'Include in library' context menu item
Function HideIncludeInLibraryMenu {
	Write-Output "Hiding 'Include in library' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -Path "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ErrorAction SilentlyContinue
}

# Show 'Include in library' context menu item
Function ShowIncludeInLibraryMenu {
	Write-Output "Showing 'Include in library' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\Folder\ShellEx\ContextMenuHandlers\Library Location" -Name "(Default)" -Type String -Value "{3dad6c5d-2167-4cae-9914-f99e41c12cfa}"
}


# Hide 'Restore previous versions' context menu item
Function HidePreviousVersionsMenu {
	Write-Output "Hiding 'Restore previous versions' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
	Remove-Item -Path "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
	Remove-Item -Path "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
	Remove-Item -Path "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
}

# Show 'Restore previous versions' context menu item
Function ShowPreviousVersionsMenu {
	Write-Output "Showing 'Restore previous versions' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\CLSID\{450D8FBA-AD25-11D0-98A8-0800361B1103}\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\Directory\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
	New-Item -Path "HKCR:\Drive\shellex\ContextMenuHandlers\{596AB062-B4D2-4215-9F74-E9109B0A8153}" -ErrorAction SilentlyContinue | Out-Null
}


# Hide 'Create a new video' context menu item
Function HideCreateANewVideoMenu {
	Write-Output "Hiding 'Create a new video' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellCreateVideo" -ErrorAction SilentlyContinue | Out-Null
	Set-ItemProperty -Path "HKCR:\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellCreateVideo" -Name "ProgrammaticAccessOnly" -Type String -Value ""
}

# Show 'Create a new video' context menu item
Function ShowCreateANewVideoMenu {
	Write-Output "Showing 'Create a new video' context menu item..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-ItemProperty -Path "HKCR:\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellCreateVideo" -Name "ProgrammaticAccessOnly" -ErrorAction SilentlyContinue | Out-Null
}


# Show Task Manager details - Applicable since 1607
# Although this functionality exist even in earlier versions, the Task Manager's behavior is different there and is not compatible with this tweak
Function ShowTaskManagerDetails {
	Write-Output "Showing task manager details..."
	$taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
	$timeout = 30000
	$sleep = 100
	Do {
		Start-Sleep -Milliseconds $sleep
		$timeout -= $sleep
		$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
	} Until ($preferences -or $timeout -le 0)
	Stop-Process $taskmgr
	if ($preferences) {
		$preferences.Preferences[28] = 0
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
	}
}

# Hide Task Manager details - Applicable since 1607
Function HideTaskManagerDetails {
	Write-Output "Hiding task manager details..."
	$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
	if ($preferences) {
		$preferences.Preferences[28] = 1
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
	}
}


# Show file operations details
Function ShowFileOperationsDetails {
	Write-Output "Showing file operations details..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
}

# Hide file operations details
Function HideFileOperationsDetails {
	Write-Output "Hiding file operations details..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -ErrorAction SilentlyContinue
}


# Enable file delete confirmation dialog
Function EnableFileDeleteConfirm {
	Write-Output "Enabling file delete confirmation dialog..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 1
}

# Disable file delete confirmation dialog
Function DisableFileDeleteConfirm {
	Write-Output "Disabling file delete confirmation dialog..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -ErrorAction SilentlyContinue
}

##########
#endregion Windows Explorer
##########



##########
#region Folder Options
##########

# Change default Explorer view to This PC
Function SetExplorerThisPC {
	Write-Output "Changing default Explorer view to This PC..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
}

# Change default Explorer view to Quick Access
Function SetExplorerQuickAccess {
	Write-Output "Changing default Explorer view to Quick Access..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -ErrorAction SilentlyContinue
}


# Hide Quick Access from Explorer navigation pane
Function HideQuickAccess {
	Write-Output "Hiding Quick Access from Explorer navigation pane..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "HubMode" -Type DWord -Value 1
}

# Show Quick Access in Explorer navigation pane
Function ShowQuickAccess {
	Write-Output "Showing Quick Access in Explorer navigation pane..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "HubMode" -ErrorAction SilentlyContinue
}


# Set Control Panel view to categories
Function SetControlPanelCategories {
	Write-Output "Setting Control Panel view to categories..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -ErrorAction SilentlyContinue
}

# Set Control Panel view to Small icons (Classic)
Function SetControlPanelSmallIcons {
	Write-Output "Setting Control Panel view to small icons..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 1
}

# Set Control Panel view to Large icons (Classic)
Function SetControlPanelLargeIcons {
	Write-Output "Setting Control Panel view to large icons..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 0
}


# Disable recent files lists
# Stops creating most recently used (MRU) items lists such as 'Recent Items' menu on the Start menu, jump lists, and shortcuts at the bottom of the 'File' menu in applications.
Function DisableRecentFiles {
	Write-Output "Disabling recent files lists..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -Type DWord -Value 1
}

# Enable recent files lists
Function EnableRecentFiles {
	Write-Output "Enabling recent files lists..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -ErrorAction SilentlyContinue
}


# Hide recently and frequently used item shortcuts in Explorer
# Note: This is only UI tweak to hide the shortcuts. In order to stop creating most recently used (MRU) items lists everywhere, use privacy tweak 'DisableRecentFiles' instead.
Function HideRecentShortcuts {
	Write-Output "Hiding recent shortcuts in Explorer..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0
}

# Show recently and frequently used item shortcuts in Explorer
Function ShowRecentShortcuts {
	Write-Output "Showing recent shortcuts in Explorer..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -ErrorAction SilentlyContinue
}


# Enable clearing of recent files on exit
# Empties most recently used (MRU) items lists such as 'Recent Items' menu on the Start menu, jump lists, and shortcuts at the bottom of the 'File' menu in applications during every logout.
Function EnableClearRecentFiles {
	Write-Output "Enabling clearing of recent files on exit..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ClearRecentDocsOnExit" -Type DWord -Value 1
}

# Disable clearing of recent files on exit
Function DisableClearRecentFiles {
	Write-Output "Disabling clearing of recent files on exit..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ClearRecentDocsOnExit" -ErrorAction SilentlyContinue
}


# Disable thumbnails, show only file extension icons
Function DisableThumbnails {
	Write-Output "Disabling thumbnails..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 1
}

# Enable thumbnails
Function EnableThumbnails {
	Write-Output "Enabling thumbnails..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 0
}


# Disable creation of thumbnail cache files
Function DisableThumbnailCache {
	Write-Output "Disabling creation of thumbnail cache files..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -Type DWord -Value 1
}

# Enable creation of thumbnail cache files
Function EnableThumbnailCache {
	Write-Output "Enabling creation of thumbnail cache files..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -ErrorAction SilentlyContinue
}


# Disable creation of Thumbs.db thumbnail cache files on network folders
Function DisableThumbsDBOnNetwork {
	Write-Output "Disabling creation of Thumbs.db on network folders..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value 1
}

# Enable creation of Thumbs.db thumbnail cache files on network folders
Function EnableThumbsDBOnNetwork {
	Write-Output "Enabling creation of Thumbs.db on network folders..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -ErrorAction SilentlyContinue
}


# Show full directory path in Explorer title bar
Function ShowExplorerTitleFullPath {
	Write-Output "Showing full directory path in Explorer title bar..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Type DWord -Value 1
}

# Hide full directory path in Explorer title bar, only directory name will be shown
Function HideExplorerTitleFullPath {
	Write-Output "Hiding full directory path in Explorer title bar..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -ErrorAction SilentlyContinue
}


# Show hidden files
Function ShowHiddenFiles {
	Write-Output "Showing hidden files..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
}

# Hide hidden files
Function HideHiddenFiles {
	Write-Output "Hiding hidden files..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
}


# Show empty drives (with no media)
Function ShowEmptyDrives {
	Write-Output "Showing empty drives (with no media)..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideDrivesWithNoMedia" -Type DWord -Value 0
}

# Hide empty drives (with no media)
Function HideEmptyDrives {
	Write-Output "Hiding empty drives (with no media)..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideDrivesWithNoMedia" -ErrorAction SilentlyContinue
}


# Show known file extensions
Function ShowKnownExtensions {
	Write-Output "Showing known file extensions..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
}

# Hide known file extensions
Function HideKnownExtensions {
	Write-Output "Hiding known file extensions..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
}


# Show folder merge conflicts
Function ShowFolderMergeConflicts {
	Write-Output "Showing folder merge conflicts..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideMergeConflicts" -Type DWord -Value 0
}

# Hide folder merge conflicts
Function HideFolderMergeConflicts {
	Write-Output "Hiding folder merge conflicts..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideMergeConflicts" -ErrorAction SilentlyContinue
}


# Show protected operating system files
Function ShowSuperHiddenFiles {
	Write-Output "Showing protected operating system files..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type DWord -Value 1
}

# Hide protected operating system files
Function HideSuperHiddenFiles {
	Write-Output "Hiding protected operating system files..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type DWord -Value 0
}


# Enable launching folder windows in a separate process
Function EnableFldrSeparateProcess {
	Write-Output "Enabling launching folder windows in a separate process..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SeparateProcess" -Type DWord -Value 1
}

# Disable launching folder windows in a separate process
Function DisableFldrSeparateProcess {
	Write-Output "Disabling launching folder windows in a separate process..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SeparateProcess" -Type DWord -Value 0
}


# Enable restoring previous folder windows at logon
Function EnableRestoreFldrWindows {
	Write-Output "Enabling restoring previous folder windows at logon..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PersistBrowsers" -Type DWord -Value 1
}

# Disable restoring previous folder windows at logon
Function DisableRestoreFldrWindows {
	Write-Output "Disabling restoring previous folder windows at logon..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PersistBrowsers" -ErrorAction SilentlyContinue
}


# Show coloring of encrypted or compressed NTFS files (green for encrypted, blue for compressed)
Function ShowEncCompFilesColor {
	Write-Output "Showing coloring of encrypted or compressed NTFS files..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowEncryptCompressedColor" -Type DWord -Value 1
}

# Hide coloring of encrypted or compressed NTFS files
Function HideEncCompFilesColor {
	Write-Output "Hiding coloring of encrypted or compressed NTFS files..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowEncryptCompressedColor" -ErrorAction SilentlyContinue
}


# Hide sync provider notifications
Function HideSyncNotifications {
	Write-Output "Hiding sync provider notifications..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
}

# Show sync provider notifications
Function ShowSyncNotifications {
	Write-Output "Showing sync provider notifications..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 1
}


# Hide item selection checkboxes
Function HideSelectCheckboxes {
	Write-Output "Hiding item selection checkboxes..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Type DWord -Value 0
}

# Show item selection checkboxes
Function ShowSelectCheckboxes {
	Write-Output "Showing item selection checkboxes..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Type DWord -Value 1
}


# Disable Sharing Wizard
Function DisableSharingWizard {
	Write-Output "Disabling Sharing Wizard..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SharingWizardOn" -Type DWord -Value 0
}

# Enable Sharing Wizard
Function EnableSharingWizard {
	Write-Output "Enabling Sharing Wizard..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SharingWizardOn" -ErrorAction SilentlyContinue
}


# Enable Explorer navigation pane expanding to current folder
Function EnableNavPaneExpand {
	Write-Output "Enabling navigation pane expanding to current folder..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -Type DWord -Value 1
}

# Disable Explorer navigation pane expanding to current folder
Function DisableNavPaneExpand {
	Write-Output "Disabling navigation pane expanding to current folder..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneExpandToCurrentFolder" -ErrorAction SilentlyContinue
}


# Show all folders in Explorer navigation pane
Function ShowNavPaneAllFolders {
	Write-Output "Showing all folders in Explorer navigation pane..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowAllFolders" -Type DWord -Value 1
}

# Hide all folders from Explorer navigation pane except the basic ones (Quick access, OneDrive, This PC, Network), some of which can be disabled using other tweaks
Function HideNavPaneAllFolders {
	Write-Output "Hiding all folders in Explorer navigation pane (except the basic ones)..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "NavPaneShowAllFolders" -ErrorAction SilentlyContinue
}


# Show Libraries in Explorer navigation pane
Function ShowNavPaneLibraries {
	Write-Output "Showing Libraries icon in Explorer namespace..."
	if (!(Test-Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}")) {
		New-Item -Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" -Name "System.IsPinnedToNameSpaceTree" -Type DWord -Value 1
}

# Hide Libraries from Explorer navigation pane
Function HideNavPaneLibraries {
	Write-Output "Hiding Libraries icon from Explorer namespace..."
	Remove-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue
}


# Enable NTFS paths with length over 260 characters
Function EnableNTFSLongPaths {
	Write-Output "Enabling NTFS paths with length over 260 characters..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\FileSystem")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\FileSystem" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 1
}

# Disable NTFS paths with length over 260 characters
Function DisableNTFSLongPaths {
	Write-Output "Disabling NTFS paths with length over 260 characters..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\FileSystem")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\FileSystem" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Type DWord -Value 0
}


# Disable updating of NTFS last access timestamps
Function DisableNTFSLastAccess {
	Write-Output "Disabling updating of NTFS last access timestamps..."
	# User Managed, Last Access Updates Disabled
	fsutil behavior set DisableLastAccess 1 | Out-Null
}

# Enable updating of NTFS last access timestamps
Function EnableNTFSLastAccess {
	Write-Output "Enabling updating of NTFS last access timestamps..."
	if ([System.Environment]::OSVersion.Version.Build -ge 17134) {
		# System Managed, Last Access Updates Enabled
		fsutil behavior set DisableLastAccess 2 | Out-Null
	} else {
		# Last Access Updates Enabled
		fsutil behavior set DisableLastAccess 0 | Out-Null
	}
}

##########
#endregion Folder Options
##########



##########
#region System & Devices
##########

# Set display timeout to standard
Function SetDisplayTimeoutStandard {
	Write-Output "Setting display timeout to standard..."
	powercfg /X monitor-timeout-ac 15 | Out-Null
	powercfg /X monitor-timeout-dc 10 | Out-Null
}

# Set display timeout to extended
Function SetDisplayTimeoutExtended {
	Write-Output "Setting display timeout to extended..."
	powercfg /X monitor-timeout-ac 25 | Out-Null
	powercfg /X monitor-timeout-dc 15 | Out-Null
}

# Set display timeout to never
Function SetDisplayTimeoutNever {
	Write-Output "Setting display timeout to never..."
	powercfg /X monitor-timeout-ac 0 | Out-Null
	powercfg /X monitor-timeout-dc 0 | Out-Null
}


# Set sleep mode sleep mode timeout to standard
Function SetSleepTimeoutStandard {
	Write-Output "Setting sleep mode timeout to standard..."
	powercfg /X standby-timeout-ac 30 | Out-Null
	powercfg /X standby-timeout-dc 20 | Out-Null
}

# Set sleep mode timeout to extended
Function SetSleepTimeoutExtended {
	Write-Output "Setting sleep mode timeout to extended..."
	powercfg /X standby-timeout-ac 45 | Out-Null
	powercfg /X standby-timeout-dc 30 | Out-Null
}

# Set sleep mode timeout to never
Function SetSleepTimeoutNever {
	Write-Output "Setting sleep mode timeout to never..."
	powercfg /X standby-timeout-ac 0 | Out-Null
	powercfg /X standby-timeout-dc 0 | Out-Null
}


# Disable Sleep start menu and keyboard button
Function DisableSleepButton {
	Write-Output "Disabling Sleep start menu and keyboard button..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type DWord -Value 0
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0 | Out-Null
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0 | Out-Null
}

# Enable Sleep start menu and keyboard button
Function EnableSleepButton {
	Write-Output "Enabling Sleep start menu and keyboard button..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type DWord -Value 1
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1 | Out-Null
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1 | Out-Null
}


# Disable Fast Startup
Function DisableFastStartup {
	Write-Output "Disabling Fast Startup..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0
}

# Enable Fast Startup
Function EnableFastStartup {
	Write-Output "Enabling Fast Startup..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 1
}


# Enable Hibernation - Do not use on Server with automatically started Hyper-V hvboot service as it may lead to BSODs (Win10 with Hyper-V is fine)
Function EnableHibernation {
	Write-Output "Enabling Hibernation..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Type DWord -Value 1
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type DWord -Value 1
	powercfg /HIBERNATE ON 2>&1 | Out-Null
}

# Disable Hibernation
Function DisableHibernation {
	Write-Output "Disabling Hibernation..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernateEnabled" -Type DWord -Value 0
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type DWord -Value 0
	powercfg /HIBERNATE OFF 2>&1 | Out-Null
}


# Disable automatic reboot on crash (BSOD)
Function DisableAutoRebootOnCrash {
	Write-Output "Disabling automatic reboot on crash (BSOD)..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\CrashControl")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\CrashControl" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type DWord -Value 0
}

# Enable automatic reboot on crash (BSOD)
Function EnableAutoRebootOnCrash {
	Write-Output "Enabling automatic reboot on crash (BSOD)..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\CrashControl")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\CrashControl" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\CrashControl" -Name "AutoReboot" -Type DWord -Value 1
}


# Enable Storage Sense - automatic disk cleanup - Applicable since 1703
Function EnableStorageSense {
	Write-Output "Enabling Storage Sense..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "StoragePoliciesNotified" -Type DWord -Value 1
}

# Disable Storage Sense - Applicable since 1703
Function DisableStorageSense {
	Write-Output "Disabling Storage Sense..."
	Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
}


# Stop and disable Windows Search indexing service
Function DisableIndexing {
	Write-Output "Stopping and disabling Windows Search indexing service..."
	Stop-Service "WSearch" -WarningAction SilentlyContinue
	Set-Service "WSearch" -StartupType Disabled
}

# Start and enable Windows Search indexing service
Function EnableIndexing {
	Write-Output "Starting and enabling Windows Search indexing service..."
	Set-Service "WSearch" -StartupType Automatic
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\WSearch" -Name "DelayedAutoStart" -Type DWord -Value 1
	Start-Service "WSearch" -WarningAction SilentlyContinue
}


# Stop and disable Superfetch service
Function DisableSuperfetch {
	Write-Output "Stopping and disabling Superfetch service..."
	Stop-Service "SysMain" -WarningAction SilentlyContinue
	Set-Service "SysMain" -StartupType Disabled
}

# Start and enable Superfetch service
Function EnableSuperfetch {
	Write-Output "Starting and enabling Superfetch service..."
	Set-Service "SysMain" -StartupType Automatic
	Start-Service "SysMain" -WarningAction SilentlyContinue
}


# Disable Recycle Bin - Files will be permanently deleted without placing into Recycle Bin
Function DisableRecycleBin {
	Write-Output "Disabling Recycle Bin..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecycleFiles" -Type DWord -Value 1
}

# Enable Recycle Bin
Function EnableRecycleBin {
	Write-Output "Enable Recycle Bin..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecycleFiles" -ErrorAction SilentlyContinue
}


# Disable scheduled defragmentation task
Function DisableDefragmentation {
	Write-Output "Disabling scheduled defragmentation..."
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" -ErrorAction SilentlyContinue | Out-Null
}

# Enable scheduled defragmentation task
Function EnableDefragmentation {
	Write-Output "Enabling scheduled defragmentation..."
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" -ErrorAction SilentlyContinue | Out-Null
}


# Enable scheduled temporary files cleanup task
Function EnableTempCleanup {
	Write-Output "Enabling scheduled temporary files cleanup.."

	if (!(Get-ScheduledTask -TaskName "$($env:USERNAME)_Run_DiskCleanupTool" -ErrorAction Ignore)) {
		$n=5000
		& CleanMgr.EXE /sageset:$n /d ($env:SystemDrive)
		
		$sta = New-ScheduledTaskAction -Execute 'cleanmgr.exe' -Argument "/sagerun:$n" -WorkingDirectory ($env:SystemDrive)
		$stt = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Sunday -At 3am
		$st = New-ScheduledTask -Action $sta -Trigger $stt -Description "Run Disk Cleanup Tool" 

		Register-ScheduledTask -InputObject $st -TaskName "$($env:USERNAME)_Run_DiskCleanupTool" | Out-Null
	}
}

# Disable scheduled temporary files cleanup task
Function DisableTempCleanup {
	Write-Output "Disabling scheduled temporary files cleanup.."
	Unregister-ScheduledTask -TaskName "$($env:USERNAME)_Run_DiskCleanupTool" -Confirm:$false -ErrorAction Ignore
}


# Disable Shared Experiences - Applicable since 1703. Not applicable to Server
# This setting can be set also via GPO, however doing so causes reset of Start Menu cache. See https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/145 for details
Function DisableSharedExperiences {
	Write-Output "Disabling Shared Experiences..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Type DWord -Value 0
}

# Enable Shared Experiences - Applicable since 1703. Not applicable to Server
Function EnableSharedExperiences {
	Write-Output "Enabling Shared Experiences..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Type DWord -Value 1
}


# Enable Clipboard History - Applicable since 1809. Not applicable to Server
Function EnableClipboardHistory {
	Write-Output "Enabling Clipboard History..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Clipboard")) {
		New-Item -Path "HKCU:\Software\Microsoft\Clipboard" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Type DWord -Value 1
}

# Disable Clipboard History - Applicable since 1809. Not applicable to Server
Function DisableClipboardHistory {
	Write-Output "Disabling Clipboard History..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -ErrorAction SilentlyContinue
}


# Disable Windows Media Player's media streaming feature
Function DisableMediaStreaming {
	Write-Output "Disabling Windows Media Player media streaming..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventLibrarySharing" -Type DWord -Value 1

	Stop-Service "WMPNetworkSvc" -WarningAction SilentlyContinue # Windows Media Player Network Sharing Service
	Set-Service "WMPNetworkSvc" -StartupType Disabled
}

# Enable Windows Media Player's media streaming feature
Function EnableMediaStreaming {
	Write-Output "Enabling Windows Media Player media streaming..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventLibrarySharing" -ErrorAction SilentlyContinue

	Set-Service "WMPNetworkSvc" -StartupType Manual
	Start-Service "WMPNetworkSvc" -WarningAction SilentlyContinue # Windows Media Player Network Sharing Service
}


# Disable Windows Media Player online access - audio file metadata download, radio presets, DRM.
Function DisableMediaOnlineAccess {
	Write-Output "Disabling Windows Media Player online access..."
	if (!(Test-Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventCDDVDMetadataRetrieval" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventMusicFileMetadataRetrieval" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventRadioPresetsRetrieval" -Type DWord -Value 1
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\WMDRM")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\WMDRM" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WMDRM" -Name "DisableOnline" -Type DWord -Value 1
}

# Enable Windows Media Player online access
Function EnableMediaOnlineAccess {
	Write-Output "Enabling Windows Media Player online access..."
	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventCDDVDMetadataRetrieval" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventMusicFileMetadataRetrieval" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\WindowsMediaPlayer" -Name "PreventRadioPresetsRetrieval" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\WMDRM" -Name "DisableOnline" -ErrorAction SilentlyContinue
}


# Disable Remote Assistance - Not applicable to Server (unless Remote Assistance is explicitly installed)
Function DisableRemoteAssistance {
	Write-Output "Disabling Remote Assistance..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "App.Support.QuickAssist*" } | Remove-WindowsCapability -Online | Out-Null
}

# Enable Remote Assistance - Not applicable to Server (unless Remote Assistance is explicitly installed)
Function EnableRemoteAssistance {
	Write-Output "Enabling Remote Assistance..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 1
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "App.Support.QuickAssist*" } | Add-WindowsCapability -Online | Out-Null
}


# Enable Remote Desktop
Function EnableRemoteDesktop {
	Write-Output "Enabling Remote Desktop..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Terminal Server")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
	Enable-NetFirewallRule -Name "RemoteDesktop*"
}

# Disable Remote Desktop
Function DisableRemoteDesktop {
	Write-Output "Disabling Remote Desktop..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\Terminal Server")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
	Disable-NetFirewallRule -Name "RemoteDesktop*"
}


# Disable System Restore for system drive - Not applicable to Server
# Note: This does not delete already existing restore points as the deletion of restore points is irreversible. In order to do that, run also following command.
# vssadmin Delete Shadows /For=$env:SYSTEMDRIVE /Quiet
Function DisableRestorePoints {
	Write-Output "Disabling System Restore for system drive..."
	Disable-ComputerRestore -Drive "$env:SYSTEMDRIVE"
}

# Enable System Restore for system drive - Not applicable to Server
# Note: Some systems (notably VMs) have maximum size allowed to be used for shadow copies set to zero. In order to increase the size, run following command.
# vssadmin Resize ShadowStorage /On=$env:SYSTEMDRIVE /For=$env:SYSTEMDRIVE /MaxSize=10GB
Function EnableRestorePoints {
	Write-Output "Enabling System Restore for system drive..."
	Enable-ComputerRestore -Drive "$env:SYSTEMDRIVE"
}


# Remove Default Fax Printer
Function RemoveFaxPrinter {
	Write-Output "Removing Default Fax Printer..."
	Remove-Printer -Name "Fax" -ErrorAction SilentlyContinue
}

# Add Default Fax Printer
Function AddFaxPrinter {
	Write-Output "Adding Default Fax Printer..."
	Add-Printer -Name "Fax" -DriverName "Microsoft Shared Fax Driver" -PortName "SHRFAX:" -ErrorAction SilentlyContinue
}


# Disable enhanced pointer precision
Function DisableEnhPointerPrecision {
	Write-Output "Disabling enhanced pointer precision..."
	if (!(Test-Path "HKCU:\Control Panel\Mouse")) {
		New-Item -Path "HKCU:\Control Panel\Mouse" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type String -Value "0"
	Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type String -Value "0"
	Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type String -Value "0"
}

# Enable enhanced pointer precision
Function EnableEnhPointerPrecision {
	Write-Output "Enabling enhanced pointer precision..."
	if (!(Test-Path "HKCU:\Control Panel\Mouse")) {
		New-Item -Path "HKCU:\Control Panel\Mouse" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type String -Value "1"
	Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type String -Value "6"
	Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type String -Value "10"
}


# Disable Autoplay
Function DisableAutoplay {
	Write-Output "Disabling Autoplay..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1
}

# Enable Autoplay
Function EnableAutoplay {
	Write-Output "Enabling Autoplay..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 0
}


# Disable Autorun for all drives
Function DisableAutorun {
	Write-Output "Disabling Autorun for all drives..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
}

# Enable Autorun for removable drives
Function EnableAutorun {
	Write-Output "Enabling Autorun for all drives..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -ErrorAction SilentlyContinue
}


# Disable accessibility keys prompts (Sticky keys, Toggle keys, Filter keys)
Function DisableAccessibilityKeys {
	Write-Output "Disabling accessibility keys prompts..."
	if (!(Test-Path "HKCU:\Control Panel\Accessibility\StickyKeys")) {
		New-Item -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"

	if (!(Test-Path "HKCU:\Control Panel\Accessibility\ToggleKeys")) {
		New-Item -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "58"

	if (!(Test-Path "HKCU:\Control Panel\Accessibility\Keyboard Response")) {
		New-Item -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type String -Value "122"
}

# Enable accessibility keys prompts (Sticky keys, Toggle keys, Filter keys)
Function EnableAccessibilityKeys {
	Write-Output "Enabling accessibility keys prompts..."
	if (!(Test-Path "HKCU:\Control Panel\Accessibility\StickyKeys")) {
		New-Item -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "510"

	if (!(Test-Path "HKCU:\Control Panel\Accessibility\ToggleKeys")) {
		New-Item -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "62"
	
	if (!(Test-Path "HKCU:\Control Panel\Accessibility\Keyboard Response")) {
		New-Item -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type String -Value "126"
}


# Disable F1 Help key in Explorer and on the Desktop
Function DisableF1HelpKey {
	Write-Output "Disabling F1 Help key..."
	if (!(Test-Path "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32")) {
		New-Item -Path "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win32" -Name "(Default)" -Type "String" -Value ""
	if (!(Test-Path "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64")) {
		New-Item -Path "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0\win64" -Name "(Default)" -Type "String" -Value ""
}

# Enable F1 Help key in Explorer and on the Desktop
Function EnableF1HelpKey {
	Write-Output "Enabling F1 Help key..."
	Remove-Item "HKCU:\Software\Classes\TypeLib\{8cec5860-07a1-11d9-b15e-000d56bfe6ee}\1.0\0" -Recurse -ErrorAction SilentlyContinue
}


# Enable NumLock after startup
Function EnableNumlock {
	Write-Output "Enabling NumLock after startup..."
	if (!(Test-Path "HKU:")) {
		New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "HKEY_USERS" | Out-Null
	}
	Set-ItemProperty -Path "HKU:\.Default\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483650
	Add-Type -AssemblyName System.Windows.Forms
	if (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
		$wsh = New-Object -ComObject WScript.Shell
		$wsh.SendKeys('{NUMLOCK}')
	}
}

# Disable NumLock after startup
Function DisableNumlock {
	Write-Output "Disabling NumLock after startup..."
	if (!(Test-Path "HKU:")) {
		New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "HKEY_USERS" | Out-Null
	}
	Set-ItemProperty -Path "HKU:\.Default\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483648
	Add-Type -AssemblyName System.Windows.Forms
	if ([System.Windows.Forms.Control]::IsKeyLocked('NumLock')) {
		$wsh = New-Object -ComObject WScript.Shell
		$wsh.SendKeys('{NUMLOCK}')
	}
}


# Enable Snap Windows feature
Function EnableWindowSnap {
	Write-Output "Enabling Snap Windows into layouts..."
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WindowArrangementActive" -Type DWord -Value 1
}

# Disable Snap Windows feature
Function DisableWindowSnap {
	Write-Output "Disabling Snap Windows into layouts..."
	if (!(Test-Path "HKCU:\Control Panel\Desktop")) {
		New-Item -Path "HKCU:\Control Panel\Desktop" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WindowArrangementActive" -Type DWord -Value 0
}


# Disable 
Function DisableShowTabsFromApps {
	Write-Output "Disabling Show tabs from apps when snapping or pressing Alt + Tab..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 3
}

# Enable Aero Shake
Function EnableShowTabsFromApps {
	Write-Output "Enabling Show tabs from apps when snapping or pressing Alt + Tab..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Type DWord -Value 0
}


# Disable Title bar window shake (minimizing other windows when one is dragged by mouse and shaken)
Function DisableWindowShake {
	Write-Output "Disabling Title bar window shake to minimize..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -Type DWord -Value 1

	if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoWindowMinimizingShortcuts" -Type DWord -Value 1

	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoWindowMinimizingShortcuts" -Type DWord -Value 1
}

# Enable Aero Shake
Function EnableWindowShake {
	Write-Output "Enabling Title bar window shake to minimize..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoWindowMinimizingShortcuts" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoWindowMinimizingShortcuts" -ErrorAction SilentlyContinue
}


# Disable Fullscreen optimizations
Function DisableFullscreenOptims {
	Write-Output "Disabling Fullscreen optimizations..."
	if (!(Test-Path "HKCU:\System\GameConfigStore")) {
		New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type DWord -Value 2
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWord -Value 2
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWord -Value 1
}

# Enable Fullscreen optimizations
Function EnableFullscreenOptims {
	Write-Output "Enabling Fullscreen optimizations..."
	if (!(Test-Path "HKCU:\System\GameConfigStore")) {
		New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWord -Value 0
	Remove-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWord -Value 0
}


# Disable Multiplane Overlay
Function DisableMPO {
	Write-Output "Disabling Multiplane Overlay..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\Dwm")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\Dwm" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Dwm" -Name "OverlayTestMode" -Type DWord -Value 5
}

# Enable Multiplane Overlay
Function EnableMPO {
	Write-Output "Enabling Multiplane Overlay..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\Dwm")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\Dwm" -Force | Out-Null
	}
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\Dwm" -Name "OverlayTestMode" -ErrorAction SilentlyContinue
}


# Set BIOS time to UTC
Function SetBIOSTimeUTC {
	Write-Output "Setting BIOS time to UTC..."
	if (!(Test-Path "HKLM:\System\CurrentControlSet\Control\TimeZoneInformation")) {
		New-Item -Path "HKLM:\System\CurrentControlSet\Control\TimeZoneInformation" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
}

# Set BIOS time to local time
Function SetBIOSTimeLocal {
	Write-Output "Setting BIOS time to Local time..."
	Remove-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -ErrorAction SilentlyContinue
}


# Add secondary en-US keyboard
Function AddENKeyboard {
	Write-Output "Adding secondary en-US keyboard..."
	$langs = Get-WinUserLanguageList
	$langs.Add("en-US")
	Set-WinUserLanguageList $langs -Force
}

# Remove secondary en-US keyboard
Function RemoveENKeyboard {
	Write-Output "Removing secondary en-US keyboard..."
	$langs = Get-WinUserLanguageList
	Set-WinUserLanguageList ($langs | Where-Object {$_.LanguageTag -ne "en-US"}) -Force
}

##########
#endregion System & Devices
##########



##########
#region Apps & Features
##########

# Disable sensor features, such as screen auto rotation
Function DisableSensors {
	Write-Output "Disabling sensors..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableSensors" -Type DWord -Value 1
}

# Enable sensor features
Function EnableSensors {
	Write-Output "Enabling sensors..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableSensors" -ErrorAction SilentlyContinue
}


# Disable automatic Maps updates
Function DisableMapUpdates {
	Write-Output "Disabling automatic Maps updates..."
	if (!(Test-Path "HKLM:\System\Maps")) {
		New-Item -Path "HKLM:\System\Maps" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\System\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0

	Stop-Service "MapsBroker" -WarningAction SilentlyContinue # Downloaded Maps Manager
	Set-Service "MapsBroker" -StartupType Disabled

	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsToastTask" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsUpdateTask" -ErrorAction SilentlyContinue | Out-Null
}

# Enable automatic Maps updates
Function EnableMapUpdates {
	Write-Output "Enable automatic Maps updates..."
	Remove-ItemProperty -Path "HKLM:\System\Maps" -Name "AutoUpdateEnabled" -ErrorAction SilentlyContinue

	Set-Service "MapsBroker" -StartupType Automatic
	Start-Service "MapsBroker" -WarningAction SilentlyContinue # Downloaded Maps Manager
	
	Enable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsToastTask" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsUpdateTask" -ErrorAction SilentlyContinue | Out-Null
}


# Disable biometric features
# Note: If you log on using biometrics (fingerprint, Windows Hello etc.) it's recommended to create a password recovery disk before applying this tweak.
Function DisableBiometrics {
	Write-Output "Disabling biometric services..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Biometrics")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Biometrics" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Biometrics" -Name "Enabled" -Type DWord -Value 0
}

# Enable biometric features
Function EnableBiometrics {
	Write-Output "Enabling biometric services..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Biometrics" -Name "Enabled" -ErrorAction SilentlyContinue
}


# Disable Cortana
Function DisableCortana {
	Write-Output "Disabling Cortana..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Personalization\Settings")) {
		New-Item -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
	if (!(Test-Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore")) {
		New-Item -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\Experience\AllowCortana" -Name "Value" -Type DWord -Value 0
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\InputPersonalization")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -Type DWord -Value 0
	Get-AppxPackage "Microsoft.549981C3F5F10" | Remove-AppxPackage
	Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ "Microsoft.549981C3F5F10" | Remove-AppxProvisionedPackage -Online | Out-Null
}

# Enable Cortana
Function EnableCortana {
	Write-Output "Enabling Cortana..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\PolicyManager\default\Experience\AllowCortana" -Name "Value" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\InputPersonalization" -Name "AllowInputPersonalization" -ErrorAction SilentlyContinue
	Get-AppxPackage -AllUsers "Microsoft.549981C3F5F10" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}


# Disable Action Center (Notification Center)
Function DisableActionCenter {
	Write-Output "Disabling Action Center (Notification Center)..."
	if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
}

# Enable Action Center (Notification Center)
Function EnableActionCenter {
	Write-Output "Enabling Action Center (Notification Center)..."
	Remove-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -ErrorAction SilentlyContinue
}


# Disable Lock screen
Function DisableLockScreen {
	Write-Output "Disabling Lock screen..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1
}

# Enable Lock screen
Function EnableLockScreen {
	Write-Output "Enabling Lock screen..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -ErrorAction SilentlyContinue
}


# Uninstall default Microsoft applications
Function UninstallMsftBloat {
	Write-Output "Uninstalling default Microsoft applications..."

	$AppsList = @(
		"Clipchamp.Clipchamp",
		"Microsoft.3DBuilder",
		"Microsoft.BingFinance",
		"Microsoft.BingFoodAndDrink",
		"Microsoft.BingHealthAndFitness",
		"Microsoft.BingMaps",
		"Microsoft.BingNews",
		"Microsoft.BingSports",
		"Microsoft.BingTranslator",
		"Microsoft.BingTravel",
		"Microsoft.BingWeather",
		"Microsoft.CommsPhone",
		"Microsoft.FreshPaint",
		"Microsoft.GamingApp",
		"Microsoft.GetHelp",
		"Microsoft.Getstarted",
		"Microsoft.HelpAndTips",
		"Microsoft.Media.PlayReadyClient.2",
		"Microsoft.Messaging",
		"Microsoft.Microsoft3DViewer",
		"Microsoft.MicrosoftOfficeHub",
		"Microsoft.MicrosoftPowerBIForWindows",
		"Microsoft.MicrosoftSolitaireCollection",
		# "Microsoft.MicrosoftStickyNotes",
		"Microsoft.MinecraftUWP",
		"Microsoft.MixedReality.Portal",
		"Microsoft.MoCamera",
		# "Microsoft.MSPaint",
		"Microsoft.NetworkSpeedTest",
		"Microsoft.Office.OneNote",
		"Microsoft.Office.Sway",
		"Microsoft.OfficeLens",
		"Microsoft.OneConnect",
		"Microsoft.People",
		"Microsoft.PowerAutomateDesktop",
		"Microsoft.Print3D",
		"Microsoft.Reader",
		"Microsoft.RemoteDesktop",
		"Microsoft.SkypeApp",
		"Microsoft.Todos",
		"Microsoft.Wallet",
		# "Microsoft.Windows.Photos",
		# "Microsoft.WindowsAlarms",
		# "Microsoft.WindowsCalculator",
		# "Microsoft.WindowsCamera",
		# "microsoft.windowscommunicationsapps",
		# "MicrosoftWindows.Client.WebExperience"
		"Microsoft.WindowsFeedbackHub",
		"Microsoft.WindowsMaps",
		"Microsoft.WindowsPhone",
		"Microsoft.WindowsReadingList",
		"Microsoft.WinJS.1.0",
		"Microsoft.WinJS.2.0",
		"Microsoft.YourPhone",
		"Microsoft.ZuneMusic",
		"Microsoft.ZuneVideo",
		"MicrosoftCorporationII.QuickAssist",
		"MicrosoftTeams"
	)

	ForEach ($App in $AppsList) {
		Get-AppxPackage $App | Remove-AppxPackage
		Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $App | Remove-AppxProvisionedPackage -Online | Out-Null
	}
}

# Install default Microsoft applications
Function InstallMsftBloat {
	Write-Output "Installing default Microsoft applications..."

	$AppsList = @(
		"Clipchamp.Clipchamp",
		"Microsoft.3DBuilder",
		"Microsoft.BingFinance",
		"Microsoft.BingFoodAndDrink",
		"Microsoft.BingHealthAndFitness",
		"Microsoft.BingMaps",
		"Microsoft.BingNews",
		"Microsoft.BingSports",
		"Microsoft.BingTranslator",
		"Microsoft.BingTravel",
		"Microsoft.BingWeather",
		"Microsoft.CommsPhone",
		"Microsoft.FreshPaint",
		"Microsoft.GamingApp",
		"Microsoft.GetHelp",
		"Microsoft.Getstarted",
		"Microsoft.HelpAndTips",
		"Microsoft.Media.PlayReadyClient.2",
		"Microsoft.Messaging",
		"Microsoft.Microsoft3DViewer",
		"Microsoft.MicrosoftOfficeHub",
		"Microsoft.MicrosoftPowerBIForWindows",
		"Microsoft.MicrosoftSolitaireCollection",
		# "Microsoft.MicrosoftStickyNotes",
		"Microsoft.MinecraftUWP",
		"Microsoft.MixedReality.Portal",
		"Microsoft.MoCamera",
		# "Microsoft.MSPaint",
		"Microsoft.NetworkSpeedTest",
		"Microsoft.Office.OneNote",
		"Microsoft.Office.Sway",
		"Microsoft.OfficeLens",
		"Microsoft.OneConnect",
		"Microsoft.People",
		"Microsoft.PowerAutomateDesktop",
		"Microsoft.Print3D",
		"Microsoft.Reader",
		"Microsoft.RemoteDesktop",
		"Microsoft.SkypeApp",
		"Microsoft.Todos",
		"Microsoft.Wallet",
		# "Microsoft.Windows.Photos",
		# "Microsoft.WindowsAlarms",
		# "Microsoft.WindowsCalculator",
		# "Microsoft.WindowsCamera",
		# "microsoft.windowscommunicationsapps",
		# "MicrosoftWindows.Client.WebExperience"
		"Microsoft.WindowsFeedbackHub",
		"Microsoft.WindowsMaps",
		"Microsoft.WindowsPhone",
		"Microsoft.WindowsReadingList",
		"Microsoft.WinJS.1.0",
		"Microsoft.WinJS.2.0",
		"Microsoft.YourPhone",
		"Microsoft.ZuneMusic",
		"Microsoft.ZuneVideo",
		"MicrosoftCorporationII.QuickAssist",
		"MicrosoftTeams"
	)

	ForEach ($App in $AppsList) {
		Get-AppxPackage -AllUsers $App | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	}
}

# In case you have removed them for good, you can try to restore the files using installation medium as follows
# New-Item C:\Mnt -Type Directory | Out-Null
# dism /Mount-Image /ImageFile:D:\sources\install.wim /index:1 /ReadOnly /MountDir:C:\Mnt
# robocopy /S /SEC /R:0 "C:\Mnt\Program Files\WindowsApps" "C:\Program Files\WindowsApps"
# dism /Unmount-Image /Discard /MountDir:C:\Mnt
# Remove-Item -Path C:\Mnt -Recurse


# Uninstall default third party applications
function UninstallThirdPartyBloat {
	Write-Output "Uninstalling default third party applications..."

	$AppsList = @(
		"2414FC7A.Viber",
		"2FE3CB00.PicsArt-PhotoStudio",
		"41038Axilesoft.ACGMediaPlayer",
		"46928bounde.EclipseManager",
		"4DF9E0F8.Netflix",
		"613EBCEA.PolarrPhotoEditorAcademicEdition",
		"64885BlueEdge.OneCalendar",
		"6Wunderkinder.Wunderlist",
		"7EE7776C.LinkedInforWindows",
		"828B5831.HiddenCityMysteryofShadows",
		"89006A2E.AutodeskSketchBook",
		"9E2F88E3.Twitter",
		"A025C540.Yandex.Music",
		"A278AB0D.DisneyMagicKingdoms",
		"A278AB0D.DragonManiaLegends",
		"A278AB0D.MarchofEmpires",
		"ActiproSoftwareLLC.562882FEEB491",
		"AD2F1837.GettingStartedwithWindows8",
		"AD2F1837.HPJumpStart",
		"AD2F1837.HPRegistration",
		"AdobeSystemsIncorporated.AdobePhotoshopExpress",
		"Amazon.com.Amazon",
		"C27EB4BA.DropboxOEM",
		"CAF9E577.Plex",
		"ClearChannelRadioDigital.iHeartRadio",
		"CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC",
		"D52A8D61.FarmVille2CountryEscape",
		"D5EA27B7.Duolingo-LearnLanguagesforFree",
		"DB6EA5DB.CyberLinkMediaSuiteEssentials",
		"DolbyLaboratories.DolbyAccess",
		"Drawboard.DrawboardPDF",
		"Facebook.Facebook",
		"Fitbit.FitbitCoach",
		"flaregamesGmbH.RoyalRevolt2",
		"Flipboard.Flipboard",
		"GAMELOFTSA.Asphalt8Airborne",
		"KeeperSecurityInc.Keeper",
		"king.com.*",
		"king.com.BubbleWitch3Saga",
		"king.com.CandyCrushFriends",
		"king.com.CandyCrushSaga",
		"king.com.CandyCrushSodaSaga",
		"king.com.FarmHeroesSaga",
		"Nordcurrent.CookingFever",
		"PandoraMediaInc.29680B314EFC2",
		"Playtika.CaesarsSlotsFreeCasino",
		"PricelinePartnerNetwork.Booking.comBigsavingsonhot",
		"ShazamEntertainmentLtd.Shazam",
		"SlingTVLLC.SlingTV",
		"SpotifyAB.SpotifyMusic",
		"TheNewYorkTimes.NYTCrossword",
		"ThumbmunkeysLtd.PhototasticCollage",
		"TuneIn.TuneInRadio",
		"WinZipComputing.WinZipUniversal",
		"XINGAG.XING"
	)

	ForEach ($App in $AppsList) {
		Get-AppxPackage $App | Remove-AppxPackage
		Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ $App | Remove-AppxProvisionedPackage -Online | Out-Null
	}
}

# Install default third party applications
Function InstallThirdPartyBloat {
	Write-Output "Installing default third party applications..."

	$AppsList = @(
		"2414FC7A.Viber",
		"2FE3CB00.PicsArt-PhotoStudio",
		"41038Axilesoft.ACGMediaPlayer",
		"46928bounde.EclipseManager",
		"4DF9E0F8.Netflix",
		"613EBCEA.PolarrPhotoEditorAcademicEdition",
		"64885BlueEdge.OneCalendar",
		"6Wunderkinder.Wunderlist",
		"7EE7776C.LinkedInforWindows",
		"828B5831.HiddenCityMysteryofShadows",
		"89006A2E.AutodeskSketchBook",
		"9E2F88E3.Twitter",
		"A025C540.Yandex.Music",
		"A278AB0D.DisneyMagicKingdoms",
		"A278AB0D.DragonManiaLegends",
		"A278AB0D.MarchofEmpires",
		"ActiproSoftwareLLC.562882FEEB491",
		"AD2F1837.GettingStartedwithWindows8",
		"AD2F1837.HPJumpStart",
		"AD2F1837.HPRegistration",
		"AdobeSystemsIncorporated.AdobePhotoshopExpress",
		"Amazon.com.Amazon",
		"C27EB4BA.DropboxOEM",
		"CAF9E577.Plex",
		"ClearChannelRadioDigital.iHeartRadio",
		"CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC",
		"D52A8D61.FarmVille2CountryEscape",
		"D5EA27B7.Duolingo-LearnLanguagesforFree",
		"DB6EA5DB.CyberLinkMediaSuiteEssentials",
		"DolbyLaboratories.DolbyAccess",
		"Drawboard.DrawboardPDF",
		"Facebook.Facebook",
		"Fitbit.FitbitCoach",
		"flaregamesGmbH.RoyalRevolt2",
		"Flipboard.Flipboard",
		"GAMELOFTSA.Asphalt8Airborne",
		"KeeperSecurityInc.Keeper",
		"king.com.*",
		"king.com.BubbleWitch3Saga",
		"king.com.CandyCrushFriends",
		"king.com.CandyCrushSaga",
		"king.com.CandyCrushSodaSaga",
		"king.com.FarmHeroesSaga",
		"Nordcurrent.CookingFever",
		"PandoraMediaInc.29680B314EFC2",
		"Playtika.CaesarsSlotsFreeCasino",
		"PricelinePartnerNetwork.Booking.comBigsavingsonhot",
		"ShazamEntertainmentLtd.Shazam",
		"SlingTVLLC.SlingTV",
		"SpotifyAB.SpotifyMusic",
		"TheNewYorkTimes.NYTCrossword",
		"ThumbmunkeysLtd.PhototasticCollage",
		"TuneIn.TuneInRadio",
		"WinZipComputing.WinZipUniversal",
		"XINGAG.XING"
	)

	ForEach ($App in $AppsList) {
		Get-AppxPackage -AllUsers $App | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	}
}


# Disable Xbox Game Bar - Not applicable to Server
Function DisableXboxGameBar {
	Write-Output "Disabling Xbox Game Bar..."
	# Disable Game Bar Tips
	if ((Get-AppxPackage -Name Microsoft.XboxGamingOverlay) -or (Get-AppxPackage -Name Microsoft.GamingApp)) {
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Type DWord -Value 0
	}

	# Disable Game bar
	Get-Process -Name GameBar, GameBarFTServer -ErrorAction Ignore | Stop-Process -Force
	Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage

	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0

	if (!(Test-Path -Path "HKCU:\System\GameConfigStore")) {
		New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0

	# Enable Open Game Bar using Xbox button on Game Controller
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\GameBar")) {
		New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0
}

# Enable Xbox Game Bar - Not applicable to Server
Function EnableXboxGameBar {
	Write-Output "Enabling Xbox Game Bar..."

	# Enable Game bar
	Get-AppxPackage -AllUsers Microsoft.XboxGamingOverlay | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

	if (!(Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 1

	if (!(Test-Path -Path "HKCU:\System\GameConfigStore")) {
		New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 1

	# Disable Game Bar Tips
	if ((Get-AppxPackage -Name Microsoft.XboxGamingOverlay) -or (Get-AppxPackage -Name Microsoft.GamingApp)) {
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Type DWord -Value 0
	}

	# Disable Open Game Bar using Xbox button on Game Controller
	if (!(Test-Path -Path "HKCU:\Software\Microsoft\GameBar")) {
		New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWord -Value 1
}


# Disable Xbox tips - Not applicable to Server
Function DisableXboxTips {
	Write-Output "Disabling Xbox Game Bar tips..."
	if ((Get-AppxPackage -Name Microsoft.XboxGamingOverlay) -or (Get-AppxPackage -Name Microsoft.GamingApp)) {
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Type DWord -Value 0
	}
}

# Enable Xbox tips - Not applicable to Server
Function EnableXboxTips {
	Write-Output "Enabling Xbox Game Bar tips..."
	if ((Get-AppxPackage -Name Microsoft.XboxGamingOverlay) -or (Get-AppxPackage -Name Microsoft.GamingApp)) {
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Type DWord -Value 1
	}
}


# Disable search for app in store for unknown extensions
Function DisableSearchAppInStore {
	Write-Output "Disabling search for app in store for unknown extensions..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
}

# Enable search for app in store for unknown extensions
Function EnableSearchAppInStore {
	Write-Output "Enabling search for app in store for unknown extensions..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -ErrorAction SilentlyContinue
}


# Disable 'How do you want to open this file?' prompt
Function DisableNewAppPrompt {
	Write-Output "Disabling 'How do you want to open this file?' prompt..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -Type DWord -Value 1
}

# Enable 'How do you want to open this file?' prompt
Function EnableNewAppPrompt {
	Write-Output "Enabling 'How do you want to open this file?' prompt..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -ErrorAction SilentlyContinue
}


# Enable Developer Mode
Function EnableDeveloperMode {
	Write-Output "Enabling Developer Mode..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
}

# Disable Developer Mode
Function DisableDeveloperMode {
	Write-Output "Disabling Developer Mode..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -ErrorAction SilentlyContinue
}


# Uninstall Windows Store
Function UninstallWindowsStore {
	Write-Output "Uninstalling Windows Store..."
	Get-AppxPackage "Microsoft.DesktopAppInstaller" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Services.Store.Engagement" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.StorePurchaseApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsStore" | Remove-AppxPackage

	Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ "Microsoft.DesktopAppInstaller" | Remove-AppxProvisionedPackage -Online | Out-Null
	Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ "Microsoft.Services.Store.Engagement" | Remove-AppxProvisionedPackage -Online | Out-Null
	Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ "Microsoft.StorePurchaseApp" | Remove-AppxProvisionedPackage -Online | Out-Null
	Get-AppXProvisionedPackage -Online | Where-Object DisplayName -EQ "Microsoft.WindowsStore" | Remove-AppxProvisionedPackage -Online | Out-Null
}

# Install Windows Store
Function InstallWindowsStore {
	Write-Output "Installing Windows Store..."
	Get-AppxPackage -AllUsers "Microsoft.DesktopAppInstaller" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Services.Store.Engagement" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.StorePurchaseApp" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsStore" | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}


# Disable OneDrive
Function DisableOneDrive {
	Write-Output "Disabling OneDrive..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\OneDrive")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\OneDrive" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
}

# Enable OneDrive
Function EnableOneDrive {
	Write-Output "Enabling OneDrive..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue
}


# Uninstall OneDrive - Not applicable to Server
Function UninstallOneDrive {
	Write-Output "Uninstalling OneDrive..."
	Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
	Start-Sleep -s 2
	$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
	if (!(Test-Path $onedrive)) {
		$onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
	}
	Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
	Start-Sleep -s 2
	Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
	Start-Sleep -s 2
	if ((Get-ChildItem -Path "$env:USERPROFILE\OneDrive" -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
		Remove-Item -Path "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	}
	Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
}

# Install OneDrive - Not applicable to Server
Function InstallOneDrive {
	Write-Output "Installing OneDrive..."
	$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
	if (!(Test-Path $onedrive)) {
		$onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
	}
	Start-Process $onedrive -NoNewWindow
}


# Set Photo Viewer association for bmp, gif, jpg, png and tif
Function SetPhotoViewerAssociation {
	Write-Output "Setting Photo Viewer association for bmp, gif, jpg, png and tif..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
		New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
		New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
		Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
		Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
	}
}

# Unset Photo Viewer association for bmp, gif, jpg, png and tif
Function UnsetPhotoViewerAssociation {
	Write-Output "Unsetting Photo Viewer association for bmp, gif, jpg, png and tif..."
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -Path "HKCR:\Paint.Picture\shell\open" -Recurse -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "MuiVerb" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "CommandId" -Type String -Value "IE.File"
	Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "(Default)" -Type String -Value "`"$env:SystemDrive\Program Files\Internet Explorer\iexplore.exe`" %1"
	Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "DelegateExecute" -Type String -Value "{17FE9752-0B5A-4665-84CD-569794602F5C}"
	Remove-Item -Path "HKCR:\jpegfile\shell\open" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\pngfile\shell\open" -Recurse -ErrorAction SilentlyContinue
}


# Add Photo Viewer to 'Open with...'
Function AddPhotoViewerOpenWith {
	Write-Output "Adding Photo Viewer to 'Open with...'"
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
	New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
}

# Remove Photo Viewer from 'Open with...'
Function RemovePhotoViewerOpenWith {
	Write-Output "Removing Photo Viewer from 'Open with...'"
	if (!(Test-Path "HKCR:")) {
		New-PSDrive -Name "HKCR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Out-Null
	}
	Remove-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Recurse -ErrorAction SilentlyContinue
}


# Hide 3D Objects
Function Hide3DObjects {
	Write-Output "Hiding 3D Objects..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	if (!(Test-Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
		New-Item -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
}

# Show 3D Objects
Function Show3DObjects {
	Write-Output "Showing 3D Objects..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" | Out-Null
	}
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue
}


# Disable built-in Adobe Flash in IE and Edge
Function DisableAdobeFlash {
	Write-Output "Disabling built-in Adobe Flash in IE and Edge..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Internet Explorer")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -Type DWord -Value 1
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Addons")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Addons" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -Type DWord -Value 0
}

# Enable built-in Adobe Flash in IE and Edge
Function EnableAdobeFlash {
	Write-Output "Enabling built-in Adobe Flash in IE and Edge..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -ErrorAction SilentlyContinue
}


# Disable Edge preload after Windows startup - Applicable since Win10 1809
Function DisableEdgePreload {
	Write-Output "Disabling Edge preload..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Type DWord -Value 0
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\TabPreloader")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Name "AllowTabPreloading" -Type DWord -Value 0
}

# Enable Edge preload after Windows startup
Function EnableEdgePreload {
	Write-Output "Enabling Edge preload..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Name "AllowTabPreloading" -ErrorAction SilentlyContinue
}


# Disable Edge desktop shortcut creation after certain Windows updates are applied
Function DisableEdgeShortcutCreation {
	Write-Output "Disabling Edge shortcut creation..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -Type DWord -Value 1
}

# Enable Edge desktop shortcut creation after certain Windows updates are applied
Function EnableEdgeShortcutCreation {
	Write-Output "Enabling Edge shortcut creation..."
	Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "DisableEdgeDesktopShortcutCreation" -ErrorAction SilentlyContinue
}


# Disable Internet Explorer first run wizard
Function DisableIEFirstRun {
	Write-Output "Disabling Internet Explorer first run wizard..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Type DWord -Value 1
}

# Enable Internet Explorer first run wizard
Function EnableIEFirstRun {
	Write-Output "Disabling Internet Explorer first run wizard..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -ErrorAction SilentlyContinue
}

##########
#endregion Apps & Features
##########



##########
#region Features on Demand
##########

# Install .NET Framework 2.0, 3.0 and 3.5 runtimes - Requires internet connection
Function InstallNET23 {
	Write-Output "Installing .NET Framework 2.0, 3.0 and 3.5 runtimes..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "NetFx3" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Install-WindowsFeature -Name "NET-Framework-Core" -WarningAction SilentlyContinue | Out-Null
	}
}

# Uninstall .NET Framework 2.0, 3.0 and 3.5 runtimes
Function UninstallNET23 {
	Write-Output "Uninstalling .NET Framework 2.0, 3.0 and 3.5 runtimes..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "NetFx3" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Uninstall-WindowsFeature -Name "NET-Framework-Core" -WarningAction SilentlyContinue | Out-Null
	}
}


# Install Hyper-V - Not applicable to Home
Function InstallHyperV {
	Write-Output "Installing Hyper-V..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Hyper-V-All" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
	}
}

# Uninstall Hyper-V - Not applicable to Home
Function UninstallHyperV {
	Write-Output "Uninstalling Hyper-V..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Hyper-V-All" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Uninstall-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
	}
}


# Uninstall Internet Explorer
Function UninstallInternetExplorer {
	Write-Output "Uninstalling Internet Explorer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -like "Internet-Explorer-Optional*" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Browser.InternetExplorer*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Internet Explorer
Function InstallInternetExplorer {
	Write-Output "Installing Internet Explorer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -like "Internet-Explorer-Optional*" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Browser.InternetExplorer*" } | Add-WindowsCapability -Online | Out-Null
}


# Uninstall Math Recognizer - Not applicable to Server
Function UninstallMathRecognizer {
	Write-Output "Uninstalling Math Recognizer..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "MathRecognizer*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Math Recognizer - Not applicable to Server
Function InstallMathRecognizer {
	Write-Output "Installing Math Recognizer..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "MathRecognizer*" } | Add-WindowsCapability -Online | Out-Null
}


# Uninstall Microsoft Print to PDF
Function UninstallPDFPrinter {
	Write-Output "Uninstalling Microsoft Print to PDF..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-PrintToPDFServices-Features" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Microsoft Print to PDF
Function InstallPDFPrinter {
	Write-Output "Installing Microsoft Print to PDF..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-PrintToPDFServices-Features" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}


# Uninstall Microsoft XPS Document Writer
Function UninstallXPSPrinter {
	Write-Output "Uninstalling Microsoft XPS Document Writer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-XPSServices-Features" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Microsoft XPS Document Writer
Function InstallXPSPrinter {
	Write-Output "Installing Microsoft XPS Document Writer..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Printing-XPSServices-Features" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}


# Uninstall OpenSSH Client - Applicable since 1803
Function UninstallSSHClient {
	Write-Output "Uninstalling OpenSSH Client..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Client*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install OpenSSH Client - Applicable since 1803
Function InstallSSHClient {
	Write-Output "Installing OpenSSH Client..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Client*" } | Add-WindowsCapability -Online | Out-Null
}


# Install OpenSSH Server - Applicable since 1809
Function InstallSSHServer {
	Write-Output "Installing OpenSSH Server..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" } | Add-WindowsCapability -Online | Out-Null
}

# Uninstall OpenSSH Server - Applicable since 1809
Function UninstallSSHServer {
	Write-Output "Uninstalling OpenSSH Server..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" } | Remove-WindowsCapability -Online | Out-Null
}


# Install Telnet Client
Function InstallTelnetClient {
	Write-Output "Installing Telnet Client..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "TelnetClient" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Install-WindowsFeature -Name "Telnet-Client" -WarningAction SilentlyContinue | Out-Null
	}
}

# Uninstall Telnet Client
Function UninstallTelnetClient {
	Write-Output "Uninstalling Telnet Client..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "TelnetClient" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Uninstall-WindowsFeature -Name "Telnet-Client" -WarningAction SilentlyContinue | Out-Null
	}
}


# Uninstall Windows Fax and Scan Services - Not applicable to Server
Function UninstallFaxAndScan {
	Write-Output "Uninstalling Windows Fax and Scan Services..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "FaxServicesClientPackage" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Print.Fax.Scan*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Windows Fax and Scan Services - Not applicable to Server
Function InstallFaxAndScan {
	Write-Output "Installing Windows Fax and Scan Services..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "FaxServicesClientPackage" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Print.Fax.Scan*" } | Add-WindowsCapability -Online | Out-Null
}


# Uninstall Windows Hello Face - Not applicable to Server
Function UninstallHelloFace {
	Write-Output "Uninstalling Windows Hello Face..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Hello.Face*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Windows Hello Face - Not applicable to Server
Function InstallHelloFace {
	Write-Output "Installing Windows Hello Face..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Hello.Face*" } | Add-WindowsCapability -Online | Out-Null
}


# Uninstall Windows Media Player
Function UninstallMediaPlayer {
	Write-Output "Uninstalling Windows Media Player..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WindowsMediaPlayer" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Media.WindowsMediaPlayer*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install Windows Media Player
Function InstallMediaPlayer {
	Write-Output "Installing Windows Media Player..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WindowsMediaPlayer" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Media.WindowsMediaPlayer*" } | Add-WindowsCapability -Online | Out-Null
}


# Uninstall PowerShell 2.0 Environment
# PowerShell 2.0 is deprecated since September 2018. This doesn't affect PowerShell 5 or newer which is the default PowerShell environment.
# May affect Microsoft Diagnostic Tool and possibly other scripts. See https://blogs.msdn.microsoft.com/powershell/2017/08/24/windows-powershell-2-0-deprecation/
Function UninstallPowerShellV2 {
	Write-Output "Uninstalling PowerShell 2.0 Environment..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "MicrosoftWindowsPowerShellV2Root" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Uninstall-WindowsFeature -Name "PowerShell-V2" -WarningAction SilentlyContinue | Out-Null
	}
}

# Install PowerShell 2.0 Environment
Function InstallPowerShellV2 {
	Write-Output "Installing PowerShell 2.0 Environment..."
	if ((Get-CimInstance -Class "Win32_OperatingSystem").ProductType -eq 1) {
		Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "MicrosoftWindowsPowerShellV2Root" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
	} else {
		Install-WindowsFeature -Name "PowerShell-V2" -WarningAction SilentlyContinue | Out-Null
	}
}


# Uninstall PowerShell Integrated Scripting Environment - Applicable since 2004
# Note: Also removes built-in graphical methods like Out-GridView
Function UninstallPowerShellISE {
	Write-Output "Uninstalling PowerShell Integrated Scripting Environment..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Microsoft.Windows.PowerShell.ISE*" } | Remove-WindowsCapability -Online | Out-Null
}

# Install PowerShell Integrated Scripting Environment - Applicable since 2004
Function InstallPowerShellISE {
	Write-Output "Installing PowerShell Integrated Scripting Environment..."
	Get-WindowsCapability -Online | Where-Object { $_.Name -like "Microsoft.Windows.PowerShell.ISE*" } | Add-WindowsCapability -Online | Out-Null
}


# Install Linux Subsystem - Applicable since Win10 1607 and Server 1709
# Note: 1607 requires also EnableDevelopmentMode for WSL to work
# For automated Linux distribution installation, see https://docs.microsoft.com/en-us/windows/wsl/install-on-server
Function InstallLinuxSubsystem {
	Write-Output "Installing Linux Subsystem..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Windows-Subsystem-Linux" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Uninstall Linux Subsystem - Applicable since Win10 1607 and Server 1709
Function UninstallLinuxSubsystem {
	Write-Output "Uninstalling Linux Subsystem..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "Microsoft-Windows-Subsystem-Linux" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}


# Uninstall Work Folders Client - Not applicable to Server
Function UninstallWorkFolders {
	Write-Output "Uninstalling Work Folders Client..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WorkFolders-Client" } | Disable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Work Folders Client - Not applicable to Server
Function InstallWorkFolders {
	Write-Output "Installing Work Folders Client..."
	Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq "WorkFolders-Client" } | Enable-WindowsOptionalFeature -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
}

##########
#endregion Features on Demand
##########



##########
#region Server Specific
##########

# Hide Server Manager after login
Function HideServerManagerOnLogin {
	Write-Output "Hiding Server Manager after login..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Server\ServerManager")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Server\ServerManager" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Server\ServerManager" -Name "DoNotOpenAtLogon" -Type DWord -Value 1
}

# Show Server Manager after login
Function ShowServerManagerOnLogin {
	Write-Output "Showing Server Manager after login..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Server\ServerManager" -Name "DoNotOpenAtLogon" -ErrorAction SilentlyContinue
}


# Disable Shutdown Event Tracker
Function DisableShutdownTracker {
	Write-Output "Disabling Shutdown Event Tracker..."
	if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows NT\Reliability")) {
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Reliability" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -Type DWord -Value 0
}

# Enable Shutdown Event Tracker
Function EnableShutdownTracker {
	Write-Output "Enabling Shutdown Event Tracker..."
	Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -ErrorAction SilentlyContinue
}


# Disable password complexity and maximum age requirements
Function DisablePasswordPolicy {
	Write-Output "Disabling password complexity and maximum age requirements..."
	$tmpfile = New-TemporaryFile
	secedit /export /cfg $tmpfile /quiet
	(Get-Content $tmpfile).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = -1") | Out-File $tmpfile
	secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $tmpfile
}

# Enable password complexity and maximum age requirements
Function EnablePasswordPolicy {
	Write-Output "Enabling password complexity and maximum age requirements..."
	$tmpfile = New-TemporaryFile
	secedit /export /cfg $tmpfile /quiet
	(Get-Content $tmpfile).Replace("PasswordComplexity = 0", "PasswordComplexity = 1").Replace("MaximumPasswordAge = -1", "MaximumPasswordAge = 42") | Out-File $tmpfile
	secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $tmpfile
}


# Disable Ctrl+Alt+Del requirement before login
Function DisableCtrlAltDelLogin {
	Write-Output "Disabling Ctrl+Alt+Del requirement before login..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 1
}

# Enable Ctrl+Alt+Del requirement before login
Function EnableCtrlAltDelLogin {
	Write-Output "Enabling Ctrl+Alt+Del requirement before login..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System")) {
		New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 0
}


# Disable Internet Explorer Enhanced Security Configuration (IE ESC)
Function DisableIEEnhancedSecurity {
	Write-Output "Disabling Internet Explorer Enhanced Security Configuration (IE ESC)..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
}

# Enable Internet Explorer Enhanced Security Configuration (IE ESC)
Function EnableIEEnhancedSecurity {
	Write-Output "Enabling Internet Explorer Enhanced Security Configuration (IE ESC)..."
	if (!(Test-Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}")) {
		New-Item -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 1
}


# Enable Audio
Function EnableAudio {
	Write-Output "Enabling Audio..."
	Set-Service "Audiosrv" -StartupType Automatic
	Start-Service "Audiosrv" -WarningAction SilentlyContinue
}

# Disable Audio
Function DisableAudio {
	Write-Output "Disabling Audio..."
	Stop-Service "Audiosrv" -WarningAction SilentlyContinue
	Set-Service "Audiosrv" -StartupType Manual
}

##########
#endregion Server Specific
##########



##########
#region Unpinning
##########

# Unpin all Start Menu tiles
# Note: This function has no counterpart. You have to pin the tiles back manually.
Function UnpinStartMenuTiles {
	Write-Output "Unpinning all Start Menu tiles..."
	if ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 16299) {
		Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Include "*.group" -Recurse | ForEach-Object {
			$data = (Get-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data").Data -Join ","
			$data = $data.Substring(0, $data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
			Set-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data" -Type Binary -Value $data.Split(",")
		}
	} elseif ([System.Environment]::OSVersion.Version.Build -ge 17134) {
		$key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
		$data = $key.Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
		Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $data
		Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
	}
}


# Unpin all Taskbar icons
# Note: This function has no counterpart. You have to pin the icons back manually.
Function UnpinTaskbarIcons {
	Write-Output "Unpinning all Taskbar icons..."
	if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Type Binary -Value ([byte[]](255))
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "FavoritesResolve" -ErrorAction SilentlyContinue
}

##########
#endregion Unpinning
##########



##########
#region Auxiliary Functions
##########

# Wait for key press
Function WaitForKey {
	Write-Output "`nPress any key to continue..."
	[Console]::ReadKey($true) | Out-Null
}


# Restart Windows Explorer
Function RestartExplorer {
	Write-Output "Restarting Windows Explorer..."
	Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
	Start-Sleep -s 2
}


# Restart computer
Function Restart {
	Write-Output "Restarting..."
	Restart-Computer
}

##########
#endregion Auxiliary Functions
##########



# Export functions
Export-ModuleMember -Function *