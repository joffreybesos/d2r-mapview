# Diablo 2: Resurrected map viewer

Noob friendly FREE map reveal tool for Diablo 2 Resurrected.  
Use at your own risk, there is no warranty or responsibility taken for being penalised for using this.

This map hack is as simple as running an executable. It relies on a backend server that is offered for free but runs on donations.  

This tool is licenced under GPLv3.

The backend map server relies on this project [blacha/diablo2](https://github.com/blacha/diablo2/tree/master/packages/map). This tool uses a modified version of that executable to generate map data.

![Durance of Hate Level 2](duranceofhate2.png)

## Demonstration

https://www.youtube.com/watch?v=-tezpjrZwEI

## Map examples

| Arcane Sanctuary |     Lower Kurast     |    Canyon of the Magi    |
| :--------------: | :------------------: | :----------------------: |
| ![](arcane.png)  | ![](lowerkurast.png) | ![](canyonofthemagi.png) |

## Installation

### Executable

1. Download the latest `d2rmap-vx.x.x.exe` and `settings.ini` files (found on the [releases page](https://github.com/joffreybesos/d2r-mapview/releases))
2. Launch D2R.
3. Run `d2rmap.exe` while in menus or in game.
4. You show see a 'Loading map data' message on the top left of the screen, this initial loading may take 10-15 seconds.
5. Make sure you press TAB to show the minimap, this map will only display when your minmap is displayed.

The executable does not require administrator unless you are running the game as administrator

### Virustotal gave me an alert

The compiled executable will get false positives in virus scans. This is because the tool is written in Autohotkey.
Autohotkey, while a powerful tool, has been used for all sorts of nefarious applications in the past.  
If you look on the Autohotkey forums, you'll see this is a widely reported problem.  

However, you can alternatively download and install <https://www.autohotkey.com/>  
Then you can run `src/d2r-map.ahk` directly from source.
This way you can be fully aware of what code you're executing and you don't have to trust an opaque executable.

Do not accept executables for this from any other source!

**Please note that running this map utility this way uses my freely hosted map server.
This server is getting hammered lately so it would be appreciated if you supported this project**.

***Bitcoin donation: `18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`***  
***D2JSP forum gold: <https://forums.d2jsp.org/user.php?i=1294529>***  

### Features

- Live player position on map
- Live monster position on map
- Unique/champion monsters live location marked on map
- Super chests specially marked (LK chests)
- All quest items, doors, waypoints marked
- Line drawn from your player position to the next level

If you want server IP to show, look at my extra standalone tool for that <https://github.com/joffreybesos/DcloneIPview>

**Map Legend**

- Green dot for player position
- White dots for normal monsters
- Large yellow dot for unique monsters
- Purple square for exits
- Yellow square for waypoints
- Most quest items should be marked with their respective icons
- Special unique monsters such as Radament and Summoner should have large red dots on their spawn location

**Other notes**

- Press Ctrl+H to see help in game
- You can exit the maphack with Shift+F10
- You can also right click the icon in the system tray.
- This MH will automatically exit when you exit D2R.
- Map download might be slow, just give it a second.
- Please ignore the message at the top, it's to alert anyone who may have been scammed.

## Discord

Join the discord server <https://discord.gg/qEgqyVW3uj>

Please report any scams or attempts to resell this maphack on discord.

## Donations

Please consider donating either some BTC or D2JSP to support this project.

Bitcoin donation `18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  
D2JSP forum gold: <https://forums.d2jsp.org/user.php?i=1294529>

## Configure

In `settings.ini` you should see some options to make configuration changes.

| Setting |     Default     |    Description    |
| :-------------- | :------------------ | :---------------------- |
| baseUrl | http://localhost:3002 | URL of the map server, set to public server by default, but you can use localhost if you [run your own server](SERVER.md) |
| maxWidth | 2000 | Maximum map image width in pixels, prevents oversized maps covering too much of the screen |
| scale | 1.1 | The global scale setting applied to all map images, press NumpadPlus and NumpadSubtract to adjust in game|
| leftMargin | 20 | The left margin of the map image, set this to wider than your primary monitor to push it onto your secondary monitor. |
| topMargin | 20 | Top margin of map image |
| opacity | 0.5 | How transparent the map image should be, between 0 and 1 |
| alwaysShowMap | false | You can show hide map with TAB key, this setting will force it to always show |
| hideTown | false | This will hide town maps so they will never show |
| showNormalMobs | true | Set to false to hide normal non-unique monsters on the map |
| showUniqueMobs | true | Set to false to hide unique monsters on the map |
| normalMobColor | FFFFFF | Colour of the dot of normal monsters |
| uniqueMobColor | D4AF37 | Colour of the dot of unique monsters |
| playerOffset | 0x20AF660 | The static memory offset, when a new D2R client is released this will need to be updated |
| uiOffset | 0x20BF322 | The offset used to determine whether your minimap is open or not |
| readInterval |  10| How long to sleep between memory reads. Increase this if you are having performance problems |
| debug| false | Turn this one to increase the level of the logging, note this will create huse `log.txt` files |

## Map Server

### Use the hosted free map server

I offer a free to use map server on the internet, but it may be slow and occasionally go down.  
If you use this server please consider donating to help with server costs.  

Bitcoin donation `18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  
D2JSP forum gold: <https://forums.d2jsp.org/user.php?i=1294529>

This free server comes preconfigured, simply use the default configuration in `settings.ini`

### Run your own map server

Alternatively you can host your own map server which I've also shared for free.  
Please refer to [SERVER.md](SERVER.md) for a full guide.

## Is it safe?

No one can say for sure. Blizzard do have Warden anti-cheat that will scan your computer for running processes and compare them against a blacklist. I accept no responsibility for any outcomes or usage of this tool. Use at your own risk!

## Troubleshooting

- A log file `log.txt` is generated in the same folder as the executable.
- You can also set debug logging to `true` in `settings.ini` for verbose logging.
- Go to the discord server if you need further help <https://discord.gg/qEgqyVW3uj>
- Tested and working on Diablo 2 Resurrected `1.0.67005`

If you are having trouble with the map server, refer to troubleshooting steps at [SERVER.md](SERVER.md)

## Licence

This repo is licenced under GPLv3

1. Anyone can copy, modify and distribute this software.
2. You have to include the license and copyright notice with each and every distribution.
3. You can use this software privately.
4. You can use this software for commercial purposes.
5. Any modifications of this code base MUST be distributed with the same license, GPLv3.
6. This software is provided without warranty.
7. The software author or license can not be held liable for any damages inflicted by the software.

Violations of the licence may make you liable for DMCA takedowns.

## TODO

- Super uniques
- Immunities
- Map image scale on a per map basis
- Shrine types
- Moving arrows on screen edge showing direction to lower level/waypoint

If you have ideas for more features, feel free to share them on discord
