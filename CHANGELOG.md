# CHANGELOG

All notable changes to this project will be documented in this file.

## [2.0.3] - 2021-11-13 - Fixed memory leak

- Fixed a memory leak regarding player position`

## [2.0.2] - 2021-11-13 - Updated offsets for new D2R client version

Updated for the new Diablo 2 Resurrected client version 1.0.67005.
Needed new offsets.
The executable hasn't changed, but thought I should keep it simple and publish a new release.

## [2.0.1] - 2021-11-11 - Player location tracking

- Map now shows the current play position with a bright green dot!
- Map now only show/hides with the normal automap (TAB to toggle) rather than always displayed
- In `settings.ini` `alwaysShowMap` can be set to true to ignore the above feature
- Refactored code to run more efficiently
- Player position and rendered on separate GDI GUI layer for better performance
- Maps now rely on their native sizing with a maximum screen width rather than hard width
- In `settings.ini` - `width` is replaced with `maxWidth` so small maps aren't overly large
- This is a major rector so expect a few issues, if you have problems, 1.2.7 will still work.

## [1.2.7] - 2021-11-08 - Hiding town maps now configurable

- Hiding of town maps can now be configured in `settings.ini` with `hideTown=true|false`

## [1.2.6] - 2021-11-07 - Town map no longer shown

- Town maps will now be hidden

## [1.2.5] - 2021-11-06 - Added loading text

- 'Loading' text now shown in place of map while map is downloading
- If map fails to download an overlayed error message will be shown
- Map will now hide when you alt-tab out of the game

## [1.2.4] - 2021-11-06 - Updated offset for new client

- Settings.ini updated with new offset for client v1.0.66878

## [1.2.3] - 2021-11-04 - Width adjustment fixed

- Fixed a bug where changing the width in settings.ini didn't work

## [1.2.2] - 2021-11-02 - Updated logging

- Logging improved, you can now turn debug logging on in settings.ini
Simply change debug=false to debug=true

## [1.2.0] - 2021-11-02 - Difficulty is read

- Difficulty is now read and used correctly

## [1.1.1] - 2021-11-02 - Minor improvements

- No longer exits sometimes when changing acts
- Map will no longer show when at menu
- Other minor optimisations

## [1.1.0] - 2021-10-28 - Better map drawing

- Better map alias smoothing
- Map is now drawn using Gdi.ahk, allows for better smoothing and performance
- Can now set position of map on screen in `settings.ini`

## [1.0.1] - 2021-10-23

- Fixed map aspect ratio to stay in proportion
- Map width can now be configured in `settings.ini`

## [1.0.0] - 2021-10-22 - Initial release

- Intial release
