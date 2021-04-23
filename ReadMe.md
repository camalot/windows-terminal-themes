# Windows Terminal Themes

These are based on [base16-xfce4-terminal](https://github.com/afq984/base16-xfce4-terminal) themes

## Installation 

- Clone this repo. 
- Identify the themes you want to install
- Run `PS> ./install-theme -Themes "theme1", "theme2" ...`
 - or install all themes: `PS> ./install-theme -All`

## Manual Installation
Find the theme you want in `./themes` directory. Copy the content to the `schemes` array in your Windows Terminal `settings.json`.

```javascript
    "schemes": [
      {
        "background": "#0C0C0C",
        "black": "#0C0C0C",
        "blue": "#0037DA",
        "brightBlack": "#767676",
        "brightBlue": "#3B78FF",
        "brightCyan": "#61D6D6",
        "brightGreen": "#16C60C",
        "brightPurple": "#B4009E",
        "brightRed": "#E74856",
        "brightWhite": "#F2F2F2",
        "brightYellow": "#F9F1A5",
        "cursorColor": "#FFFFFF",
        "cyan": "#3A96DD",
        "foreground": "#CCCCCC",
        "green": "#13A10E",
        "name": "Campbell",
        "purple": "#881798",
        "red": "#C50F1F",
        "selectionBackground": "#FFFFFF",
        "white": "#CCCCCC",
        "yellow": "#C19C00"
      },
      {
        ...
      },
      ...
      // insert new theme(s) here
    ]
```

## Uninstall Themes

- Run `PS> ./install-theme -Themes "theme1", "theme2" -Uninstall`
 - or uninstall all themes: `PS> ./install-theme -All -Uninstall`
