# Diablo 2: Resurrected map viewer

Noob friendly FREE map overlay tool for Diablo 2 Resurrected.  
Use at your own risk, there is no warranty or responsibility taken for being penalised for using this.

This tool is licenced under GPLv3, reselling this maphack violates the terms of the license.

## Bans

Blizzard did a ban wave on June 14 where it seems they targeted MapAssist (another map hack).  
This map hack is very similar in how it functions.  
While most users of this map hack were spared, **it is recommended to consider this map hack detectable online**.

## Join the discord server <https://discord.gg/qEgqyVW3uj>

![Worldstone Keep level 2](https://user-images.githubusercontent.com/93067706/170401221-10e7a71e-7cad-488d-98e0-69f4d3617332.png)

## Demonstration

<https://youtu.be/tSDmgh0ceXk> (needs an update)

## Map examples

|    Stony Field     |   Lower Kurast     |        Travincal         | Harrogath    |
| :---------------: | :------------------: | :----------------------: | :-----------------: |
| ![image](https://user-images.githubusercontent.com/93067706/170401476-5f13bdf9-57eb-40a4-a736-a508c21d854a.png)| ![image](https://user-images.githubusercontent.com/93067706/170401546-4bb935f1-722f-429b-bf1a-07701db672c3.png) |![image](https://user-images.githubusercontent.com/93067706/170401603-170e38f0-864d-4375-8db8-1a3ed1fbcc75.png) | ![image](https://user-images.githubusercontent.com/93067706/170441186-e7bd7813-48ae-4355-8491-30f0a19c0222.png) |

## Setup

Set up guide has moved to the wiki:
https://github.com/joffreybesos/d2r-mapview/wiki/Setup-guide

- Press Ctrl+H in game for a help menu
- Press Ctrl+O for in game options

The executable does _not_ require administrator privileges unless you are running the game as administrator. Refer to troubleshooting below if you have issues.  
Sometimes windows defender can intercept the download, try a different browser if this happens.

### Virustotal gave me an alert

The compiled executable will get false positives in virus scans. This is because the tool is written in Autohotkey.
Autohotkey, while a powerful tool, has been used for all sorts of nefarious applications in the past.  
If you look on the Autohotkey forums, you'll see this is a widely reported problem.
This tool reads from memory and hooks into global hotkeys which as a general throws up flags in certain virus scanners.

If you still don't trust it, you can run directly from source which is very easy.
To do so download and install <https://www.autohotkey.com/>  
Then you can simply double click the file `src/d2r-map.ahk` to run from source code.
This way you can be fully aware of what code you're executing and you don't have to trust an opaque executable.

Do not accept executables for this from any other source!

### Usage

Start D2R, then start the MH, you should see text in the top left corner.

- Press `Ctrl+H` to see help in game, including a map legend
- Press `Ctrl+O` for in game options
- Press `\` to switch map to the left corner.
- You can exit the maphack with `Shift+F10`
- You can reload the maphack with `Shift+F11`
- You can also right click the icon in the system tray.
- This MH will automatically exit when you exit D2R.

## Features

- The map will show:
  - Players
  - Monsters
  - Immunities
  - Item drop alerts with a customisable filter
  - Text to speech to announce dropped special items defined in your item filter
  - Shows shrines and their type
  - Portals
  - All doors and waypoints marked
  - A purple line drawn to the next level exit
  - A yellow line drawn to the waypoint
  - A red line drawn to the nearest boss (Nihlithak, summoner etc)
  - All quest items, marked in green (Stones, Hellforge, Altars etc)
- Displays game history in game menu (which is also saved to a file)  
  ![Game History](https://user-images.githubusercontent.com/93067706/170401732-01bdc8b0-f3bf-4e6e-9fac-99be2df5b078.png)  
- Counters onthe side to show number of scrolls and keys  
  ![Item counters](https://user-images.githubusercontent.com/93067706/170401856-23dee23d-f9ad-47fc-bcfe-3360bc33433a.png)
- Party member locations and plevel are added under their icon  
  ![Party Members](https://user-images.githubusercontent.com/93067706/170402837-79ede3d2-06a0-406b-9764-212a3f8d073c.png)
- Shows health bars above bosses on the map  
  ![Boss health bart](https://user-images.githubusercontent.com/93067706/170402107-af6de885-802f-49e0-aabb-366bcaddc831.png)  
- When you mouse over a monster, you can see their resistances and health percentage  
  ![Resists](https://user-images.githubusercontent.com/93067706/170402204-9bfe6cf9-9043-4a20-8ea0-5a3455bf4631.png)  
- When items drop that match the item filter it can display all of the stats of that item  
  ![Item stats](https://user-images.githubusercontent.com/93067706/170402401-388dd690-a011-48ce-b497-8c4487a98277.png)  
- Highly configurable, size, color, position, opacity etc  
- Can change map size and position with key shortcuts while in game  



## Discord

Join the discord server <https://discord.gg/qEgqyVW3uj>
Please report any scams or attempts to resell this maphack on discord.

## Donations

Please consider donating either some BTC or D2JSP to support this project.

Bitcoin donation `18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  
BEP20 BUSD address `0xb77638fec7fb7ac2064f5fc754980404835fe9a3`  
D2JSP forum gold: <https://forums.d2jsp.org/user.php?i=1294529>

### Configure

Press Ctrl+O in game for settings, and you can delete your settings.ini to restore all settings to defaults.

## Map Server

This tool relies on a mapserver which is a separate project https://github.com/joffreybesos/d2-mapserver  
However you can download the bundle from the setup guide or from discord which includes everything you need.

## Is it safe?

No one can say for sure. Blizzard do have Warden anti-cheat that will scan your computer for running processes and compare them against a blacklist. I accept no responsibility for any outcomes or usage of this tool. Use at your own risk!

## Troubleshooting

Refer to <https://github.com/joffreybesos/d2r-mapview/wiki/Setup-guide#troubleshooting>  

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

## Kudos

- @blacha and his [Diablo 2 map package](https://github.com/blacha/diablo2/tree/master/packages/map)
- @OneXDeveloper @ItzRabbs and others at [MapAssist](https://github.com/OneXDeveloper/MapAssist)
- @noah- and [d2bs project](https://github.com/noah-/d2bs/blob/master/D2Structs.h)

![mapviewimage](https://user-images.githubusercontent.com/93067706/183021907-89636339-92d7-4022-b784-b82efb9cfb18.png)
