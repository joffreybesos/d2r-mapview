# Diablo 2: Resurrected map viewer

Noob friendly map reveal for Diablo 2 Resurrected.
This is to be used for educational purposes only!
Use at your own risk, there is no warranty or responsibility taken for being penalised for using this.

This repo will fetch the map from a backend map server and display it in the top left corner of your D2R window as shown below:

![Worldstone Keep Level 2](worldstonekeep2.png)

## Usage

1. Download the latest release (on the right side).
2. Launch D2R.
3. Run the `d2rmap.exe`
4. Map should appear at the top left and change as you move through the levels.

Note:

- Purple icon for exits
- Yellow for waypoints
- Red for NPCs
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
Or alternatively you can run the `/bin/d2rmap.exe` executable, which does the same thing.

2. Map server:
You need a running map service to send mapseed/id/difficulty values and return an image.
This map server is not in this repository (but coming soon!)
However it hosted on the internet for you to use.
If you use my hosted map server, please consider donating to help with hosting costs.

## How it works

This script will run the background and read player data directly from memory.
It will retrieve the mapseed/level/difficulty and send a request to a mapserver hosted separately.
This mapserver will return a map image.
This script will display that map image in the corner as shown in the above screenshot.

This script will exit if D2R is not running or exits.

## Troubleshooting

Refer to `log.txt` to view any error messages.

Tested and working on Diablo 2 Resurrected 1.0.66606

## Donations

If you'd like to donate, please send to my Bitcoin wallet below
`18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`  
