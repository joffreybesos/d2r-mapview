# Diablo 2: Resurrected map viewer

This repo will fetch the map from a backend map server and display it in the top left corner of your D2R window as shown below:

![Worldstone Keep Level 2](worldstonekeep2.png)

## Setup

This is in two parts:

1. This repository:
This repo is an AutoHotKey script, you can either install AutoHotkey which will allow you to run `d2r-map.ahk`.
Or alternatively you can run the `/bin/d2rmap.exe` executable, which does the same thing.

2. Map server:
You need a running map service to send mapseed/id/difficulty values and return an image.
This map server is not in this repository (but coming soon!)

## How it works

This script will run the background and read player data directly from memory.
It will retrieve the mapseed/level/difficulty and send a request to a mapserver hosted separately.
This mapserver will return a map image.
This script will display that map image in the corner as shown in the above screenshot.

This script will exit if D2R is not running or exits.

## Troubleshooting

Refer to `log.txt` to view any error messages.

Tested and working on Diablo 2 Resurrected 1.0.66606

### Donations

If you'd like to donate, please send to my Bitcoin wallet below
`18hSn32hChp1CmBYnRdQFyzkz5drpijRa2`