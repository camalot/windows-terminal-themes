 # Requires -Version 6

[CmdletBinding(DefaultParameterSetName = 'SpecifiedThemes')]
param(
	[ArgumentCompleter( { Get-ChildItem -Path "./themes" -Exclude ".all.json" | ForEach-Object { $_.BaseName } })]
	[Parameter(Mandatory = $false, ParameterSetName = 'AllThemes')]
	[Parameter(Mandatory = $true, ParameterSetName = 'SpecifiedThemes')]
	[string[]] $Themes,
	[Parameter(ParameterSetName = 'AllThemes')]
	[switch] $All,
	[switch] $Uninstall,
	[switch] $Force
)

$settingsPath = "${Env:LOCALAPPDATA}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json";
$settingsData = (Get-Content -Path $settingsPath -Raw) -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/' | ConvertFrom-Json;

function Install-WindowsTerminalTheme {
	param(
		[string] $Theme
	)
	begin {
		$themeObject = Get-Content -Path ".\themes\$Theme.json" -Raw | ConvertFrom-Json;
	}
	process {
		if ( Test-ThemeExists -Theme $themeObject.name -Settings $settingsPath) {
			if ($Force) {
				Uninstall-WindowsTerminalTheme -Theme $Theme;
				Install-WindowsTerminalTheme -Theme $Theme;
			} else {
				"Theme '$($themeObject.name)' Exists. Skipping. Use -Force Flag." | Write-Host;
			}
		}
		else {
			"Adding $($themeObject.name) to settings schemes." | Write-Host;
			if ($themeObject -ne $null) {
				$settingsData.schemes += $themeObject;
			}
		}
	}
}

function Uninstall-WindowsTerminalTheme {
	param(
		[string] $Theme
	)
	begin {
		$themeObject = Get-Content -Path ".\themes\$Theme.json" -Raw | ConvertFrom-Json;
	}
	process {
		if ( Test-ThemeExists -Theme $themeObject.name -Settings $settingsPath) {
			"Removing '$($themeObject.name)' from schemes." | Write-Host;
			$newSchemes = $settingsData.schemes | Where-Object { $_.name -ine $themeObject.name };
			$settingsData.schemes = $newSchemes;
		}
		else {
			"Theme Not Found. Skipping." | Write-Host;
		}
	}
}

function Create-Backup {
	$settingsFolder = (Get-Item -Path $settingsPath).Directory;
	# settings.json.2021-04-21T18-33-35
	$dt = Get-Date -Format "yyyy-MM-ddTHH-mm-ss";
	"Generating Backup: `"settings.json.$dt.backup`"" | Write-Host;
	Copy-Item -Path $settingsPath -Destination (Join-Path -Path $settingsFolder -ChildPath "settings.json.$dt.backup") | Out-Null;
}

function Install-AllThemes {
	(Get-ChildItem -Path "./themes/" -Exclude ".all.json") | ForEach-Object {
		Install-WindowsTerminalTheme -Theme $_.BaseName;
	}
}

function Uninstall-AllThemes {
	(Get-ChildItem -Path "./themes/" -Exclude ".all.json") | ForEach-Object {
		Uninstall-WindowsTerminalTheme -Theme $_.BaseName;
	}
}

function Test-ThemeExists {
	param (
		[string] $Theme,
		[string] $Settings
	)
	$settingsData = Get-Content -Path $Settings -Raw | ConvertFrom-Json;
	try {
		$settingsData.schemes | ForEach-Object {
			if ( $_.name -ieq $Theme ) {
				return $true;
			}
		}
		return $false;
	}
	catch {
		"$($_.Exception.ToString())" | Write-Output;
		return false;
	}
}


# Create a backup
Create-Backup;
if ( $Uninstall ) {
	if ( $All ) {
		Uninstall-AllThemes;
	}
	else {
		$Themes | ForEach-Object {
			Uninstall-WindowsTerminalTheme -Theme $_
		}
	}
}
else {
	if ( $All ) {
		Install-AllThemes;
	}
	else {
		$Themes | ForEach-Object {
			Install-WindowsTerminalTheme -Theme $_
		}
	}
}
# Save the changes
Set-Content -Path $settingsPath -Value (ConvertTo-Json $settingsData -Depth 10) | Out-Null;
