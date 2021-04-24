#!/usr/bin/env pwsh

$all = @{
	schemes = [System.Collections.ArrayList]@();
}
function Get-Base16Themes {
	# Invoke-RestMethod -Uri "https://api.github.com/repos/afq984/base16-xfce4-terminal/contents/colorschemes" -Method Get |
	$items = (Invoke-WebRequest -Uri "https://api.github.com/repos/afq984/base16-xfce4-terminal/contents/colorschemes" -Method Get).Content  | ConvertFrom-Json;
	# $items = Get-Content -Path "./temp.json" | ConvertFrom-Json;


	$items | ForEach-Object {
		$item = $_;
		$name = $item.name -replace "base16-", "";
		if ( $name -notlike "*.16.theme" ) {
			$themeData = (Invoke-WebRequest -Uri "$($item.download_url)" -Method Get).Content
			$theme = @{};
			$settings = Read-ThemeFile -Content ($themeData -split "`n");
			$palette = $settings.ColorPalette -split ";";

			$fileName = Clean-FileName -InputFileName ($name -replace ".theme", ".json");

			$theme['name'] = $settings.Name;
			$theme['background'] = $settings.ColorBackground;
			$theme['foreground'] = $settings.ColorForeground;
			if ($settings.ColorCursor -imatch "`#[a-f0-9]{6}") {
				$theme['cursorColor'] = $settings.ColorCursor;
			}
			else {
				if ($settings.ColorBoldIsBright -eq "TRUE") {
					$theme['selectionBackground'] = $palette[4];
					$theme['cursorColor'] = $palette[7];
				}
				else {
					$theme['selectionBackground'] = $palette[12];
					$theme['cursorColor'] = $palette[15];
				}
			}
			$theme['black'] = $palette[0];
			$theme['red'] = $palette[1];
			$theme['green'] = $palette[2];
			$theme['yellow'] = $palette[3];
			$theme['blue'] = $palette[4];
			$theme['purple'] = $palette[5];
			$theme['cyan'] = $palette[6];
			$theme['white'] = $palette[7];

			$theme['brightBlack'] = $palette[8];
			$theme['brightRed'] = $palette[9];
			$theme['brightGreen'] = $palette[10];
			$theme['brightYellow'] = $palette[11];
			$theme['brightBlue'] = $palette[12];
			$theme['brightPurple'] = $palette[13];
			$theme['brightCyan'] = $palette[14];
			$theme['brightWhite'] = $palette[15];
			"Generating Theme File for $($theme.name)" | Out-Host;
			$all.schemes.Add($theme) | Out-Null;
			Set-Content -Path "./themes/$($fileName.ToLower())" -Force -Value ($theme | ConvertTo-Json -Depth 10);
		}
	}
}

function Get-iTerm2Themes {
	#https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/windowsterminal
	$items = (Invoke-WebRequest -Uri "https://api.github.com/repos/mbadolato/iTerm2-Color-Schemes/contents/windowsterminal" -Method Get).Content  | ConvertFrom-Json;
	$items | ForEach-Object {
		$item = $_;
		$fileName = Clean-FileName -InputFileName $item.name
		"Checking for $($item.name)" | Write-Host;
		$existing = (Get-ChildItem -Path "./themes" -Include $fileName);
		if ( $null -eq $existing ) {
			$theme = (Invoke-WebRequest -Uri "$($item.download_url)" -Method Get).Content;
			$all.schemes.Add(($theme | ConvertFrom-Json)) | Out-Null;
			Set-Content -Path "./themes/$fileName" -Force -Value $theme;
		}
	}
}

function Clean-FileName {
	param (
		[string] $InputFileName
	)
	return ($InputFileName -replace "\s", "-").ToLower();
}

function Read-ThemeFile {
	param (
		[string[]] $Content
	)
	begin {
		$theme = @{}
	}
	process {
		$lines = $Content;
		$lines | ForEach-Object {
			switch -regex ($_) {
				"^\s*([^#].+?)\s*=\s*(.*)" {
					$name, $value = $matches[1..2];
					# skip comments that start with semicolon:
					if (!($name.StartsWith(";"))) {
						$theme[$name] = $value.Trim() -replace "Base16-", "";
					}
				}
			}
		}
	}
	end {
		return $theme;
	}
}
Get-iTerm2Themes;
Get-Base16Themes;

Set-Content -Path "./themes/.all.json" -Force -Value ($all | ConvertTo-Json -Depth 10);
