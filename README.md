# B.O.N.K.

**B.O.N.K.** is a small 2D multiplayer arena game.

Inspired by chaotic local multiplayer games, B.O.N.K. aims to build its own characters, abilities, weapons and arenas.

## Status

🚧 Early development

## Tech

- [Odin](https://odin-lang.org/)
- [raylib](https://www.raylib.com/)

## Platform

Currently targeting **macOS**.

## Project structure

- `src/main.odin` - application entry point and main loop
- `src/game/` - game simulation and rules
- `src/input/` - keyboard, controller and other input handling
- `src/render/` - drawing and presentation
- `src/network/` - LAN multiplayer and synchronization
- `assets/` - sprites, maps, sounds and music

raylib provides the window, rendering, input and audio APIs. Odin contains the
game simulation and networking code.

## Build and run

With Odin and raylib installed:

```sh
odin build src -out:bin/bonk
./bin/bonk
```
