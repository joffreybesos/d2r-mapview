# Diablo 2: Resurrected map viewer

Noob friendly map reveal for Diablo 2 Resurrected.  
Use at your own risk, there is no warranty or responsibility taken for being penalised for using this.

This repo will fetch the map from a backend map server and display it in the top left corner of your D2R window as shown below.
The player position will also be shown with a bright green dot.

![Durance of Hate Level 2](duranceofhate2.png)

## Map examples

| Arcane Sanctuary |     Lower Kurasy     |    Canyon of the Magi    |
| :--------------: | :------------------: | :----------------------: |
| ![](arcane.png)  | ![](lowerkurast.png) | ![](canyonofthemagi.png) |

## Installation

1. Download the latest `d2rmap-vx.x.x.exe` and `settings.ini` files (found on the [releases page](https://github.com/joffreybesos/d2r-mapview/releases))
2. Launch D2R.
3. Run `d2rmap.exe` while in menus or in game.
4. You show see a 'Loading map data' message on the top left of the screen, this initial loading may take 10-15 seconds.
5. Make sure you press TAB to show the minimap, this map will only display when your minmap is displayed.

**Please note that running this map utility this way uses my freely hosted map server.
This server is getting hammered lately so it would be appreciated if you supported this project**.

***Bitcoin donation: `18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`***  
***D2JSP forum gold: <https://forums.d2jsp.org/user.php?i=1294529>***  

**Map Legend**

- Purple square for exits
- Yellow square for waypoints
- Red dot for NPCs
- Most quest items should be marked with their respective icons

**Other notes**

- You can exit the maphack with Shift+F10
- You can also right click the icon in the system tray.
- This MH will automatically exit when you exit D2R.
- Map download might be slow, just give it a second.
- Please consider donating to help support the project (and server costs).

## Run from source

If you don't trust a precompiled executable, you can alternatively download and install <https://www.autohotkey.com/>  
Then you can run `src/d2r-map.ahk` directly from source.
This way you can verify the code yourself and ensure there are no hidden macros.

Do not accept executables for this from any other source!

## Discord

Join the discord server <https://discord.gg/qEgqyVW3uj>

Please report any scams or attempts to resell this maphack on discord.

## Donations

Please consider donating either some BTC or D2JSP to support this project.

Bitcoin donation `18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  
D2JSP forum gold: <https://forums.d2jsp.org/user.php?i=1294529>

## Configure

In `settings.ini` you should see some options to make configuration changes.

- You can change the map opacity, setting 0-1, 1 being more opaque. Default is 0.5.
- If you want the map to appear on a second display, change the `leftMargin` value in `settings.ini` to be larger than the width of your primary monitor (in pixels). Negative values also work.

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

## TODO

- Need to add more info for NPCs and others
- Option to change the map to a floating window
- Path finding algorithm?
- Indicate on the screen which way waypoints/exits are relative to your position

If you have ideas for more features, feel free to share them on discord
