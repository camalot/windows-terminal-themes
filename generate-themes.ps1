#!/usr/bin/env pwsh

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

      $theme['name'] = $settings.Name;
      $theme['background'] = $settings.ColorBackground;
      $theme['foreground'] = $settings.ColorForeground;
      if ($settings.ColorCursor -imatch "`#[a-f0-9]{6}") {
        $theme['cursorColor'] = $settings.ColorCursor;
      } else {
        if ($settings.ColorBoldIsBright -eq "TRUE") {
          $theme['selectionBackground'] = $palette[4];
          $theme['cursorColor'] = $palette[7];
        } else {
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

      Set-Content -Path "./themes/$name" -Force -Value ($theme | ConvertTo-Json)
    }
  }
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

Get-Base16Themes;
