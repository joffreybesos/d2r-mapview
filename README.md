# Diablo 2: Resurrected map viewer

Noob friendly map reveal for Diablo 2 Resurrected.  
This is to be used for educational purposes only!  
Use at your own risk, there is no warranty or responsibility taken for being penalised for using this.  

This repo will fetch the map from a backend map server and display it in the top left corner of your D2R window as shown below:

![Durance of Hate Level 2](duranceofhate2.png)

## Usage

1. Download the latest `d2rmap-vx.x.x.exe` and `settings.ini` release files (link to the right).
2. Launch D2R.
3. Run `d2rmap.exe` in menus or in game.
4. Map should appear at the top left and change as you move through the levels. (It might take a few seconds to first appear)

That's the lazy method, however running unknown executables is not a great idea in general.  
There have been cases in the past with D2 scripts that make you drop all your gear and exit the game!  

Instead you can download and install <https://www.autohotkey.com/>  
Then you can directly run `src/d2r-map.ahk` instead of the executable.  
At least then you can verify the code yourself and ensure there are no hidden macros.  

Do not accept executables for this from any other source!

**Notes:**

- Purple icon for exits
- Yellow for waypoints
- Red for NPC
- Cyan for chests  
- A tray icon will be present which you can right click to exit.
- This script will exit when you exit D2R.
- You can exit with Shift+F10 hotkey
- Map download might be slow when it's retrieving from my backend server.
- Please consider donating to help support the project (and server costs).

## Discord

Join the discord server  <https://discord.gg/qEgqyVW3uj>

## Donations

Please consider donating some Bitcoin to support this project:  
`18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  

## Setup

You can change map size and opacity in `settings.ini`  

This is in two parts:

1. This repository:
This repo is an AutoHotKey script, you can either install AutoHotkey which will allow you to run `d2r-map.ahk`.  
Or alternatively you can run the `d2rmap.exe` latest release, which does the same thing.

2. Map server:
You need a running map service to send mapseed/id/difficulty values and return an image.

### Use a hosted free map server

There is a hosted one on the internet which you are free to use, but may be slow and occasionally go down.  
If you use this server please consider donating to help with server costs.  
If you'd like to donate, some BTC will be appreciated:  
`18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  
To use this server, simply use the existing configuration in `settings.ini`

### Run your own map server

You need an installation of Diablo 2 LOD 1.13c (__NOT resurrected!__).  
The map server uses the old Diablo 2 code to generate maps, since the maps are identical in D2R.

- Install Diablo 2, the LoD expansion, then the 1.13c patch.  
- Install [Docker](https://docs.docker.com/get-docker/)  

Then you can use docker to run:  

- `docker pull docker.io/joffreybesos/d2-mapserver`

In the below docker command, change `/d/temp` to a temporary folder on your PC to save map data and change `/d/Games/Diablo II` to your D2 installion folder:

- `docker run -v "/d/temp:/app/cache" -v "/d/Games/Diablo II":/app/game -p 3002:3002 -e PORT=3002 joffreybesos/d2-mapserver:latest`

You should eventually see the text `Running on http://0.0.0.0:3002`

- Once the server is working, edit your `settings.ini` file.  
  Change `baseurl` to this: `baseUrl=http://localhost:3002`

You can test your map server by opening the URL <http://localhost:3002/v1/map/123456/2/46/image> in your browser.

## How it works

This script will run the background and read player data directly from memory.  
It will retrieve the mapseed/level/difficulty and send a request to a mapserver hosted separately.  
This mapserver will return a map image.  
This script will display that map image in the corner as shown in the above screenshot.  

This script will exit if D2R is not running or exits.  

## Is it safe?

No one can say for sure. Blizzard do have Warden anti-cheat that will scan your computer for running processes and compare them against a blacklist. I accept no responsibility for any outcomes or usage of this tool. Use at your own risk!

## Troubleshooting

A log file `log.txt` is generated in the same folder as the executable.

You can also set debug logging to `true` in `settings.ini` for verbose logging.

Go to the discord server if you need further help <https://discord.gg/qEgqyVW3uj>  

Tested and working on Diablo 2 Resurrected `1.0.66606`

## TODO

- Need to add more info for NPCs and others
- Replace coloured blocks with icons
