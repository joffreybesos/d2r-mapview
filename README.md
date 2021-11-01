# Diablo 2: Resurrected map viewer

Noob friendly map reveal for Diablo 2 Resurrected.  
This is to be used for educational purposes only!  
Use at your own risk, there is no warranty or responsibility taken for being penalised for using this.  

This repo will fetch the map from a backend map server and display it in the top left corner of your D2R window as shown below:

![Durance of Hate Level 2](duranceofhate2.png)

## Usage

1. Download the latest `drrmap.exe` release (on the right side).
2. Launch D2R.
3. Run the `d2rmap.exe`
4. Map should appear at the top left and change as you move through the levels.

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
- Map download might be slow as it's retrieving from my backend server.
- Please consider donating to help with server costs.

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

You need an installation of Diablo 2 LOD 1.13c (NOT resurrected!).  
The map server uses the old Diablo 2 code to generate maps, since they are identical in D2R.

Install Diablo 2, the LoD expansion, then the 1.13c patch.  
You must also install [Docker](https://docs.docker.com/get-docker/)  

Then you can use docker to run:  
`docker pull docker.io/joffreybesos/d2-mapserver`  
`docker run -v "./:/app/cache" -v "/c/Program Files (x86)/Diablo II":/app/game -p 3002:3002 -e PORT=3002 joffreybesos/d2-mapserver:latest`

Once it's running port 3002, edit your `settings.ini` file.  
Change `baseurl` to this: `baseUrl=http://0.0.0.0:3002`

## How it works

This script will run the background and read player data directly from memory.  
It will retrieve the mapseed/level/difficulty and send a request to a mapserver hosted separately.  
This mapserver will return a map image.  
This script will display that map image in the corner as shown in the above screenshot.  

This script will exit if D2R is not running or exits.  

## Troubleshooting

Refer to `log.txt` to view any error messages.  
Go to the discord server if you need further help <https://discord.gg/qEgqyVW3uj>  
Tested and working on Diablo 2 Resurrected `1.0.66606`

## Discord

Join the discord server  <https://discord.gg/qEgqyVW3uj>

## TODO

- Currently only reads maps for Hell difficulty  
- Need to add more info for NPCs and others
- Replace coloured blocks with icons
- BUG: It will sometimes unintentionally exit when switching acts

## Donations

If you'd like to donate, some BTC will be appreciated:  
`18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  
