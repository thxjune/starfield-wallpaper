# Starfield Wallpaper

An animated starfield desktop wallpaper for macOS — a pure black background with slowly drifting, twinkling stars in three parallax depth layers, plus the occasional shooting star. No dependencies, no third-party apps: one HTML file for the animation and a ~90-line Swift program that pins it behind your desktop icons.

## How it works

- **`starfield.html`** — the animation, rendered on a `<canvas>`. Delta-time movement (framerate-independent), Retina-aware scaling, and slow parallax drift so it never looks choppy.
- **`main.swift`** — creates a borderless window at desktop window level (above the wallpaper image, below the desktop icons) on every screen, hosting a `WKWebView` that loads the HTML. Clicks pass through to the desktop. Rebuilds automatically when displays change.

Runs at roughly 5% CPU on Apple Silicon.

## Build

```sh
swiftc -O main.swift -o StarfieldWallpaper
```

(If your Command Line Tools hit the duplicate `SwiftBridging` module bug, compile with a full Xcode toolchain instead: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swiftc -O main.swift -o StarfieldWallpaper`.)

## Run

```sh
./StarfieldWallpaper &
```

Stop it with:

```sh
pkill -x StarfieldWallpaper
```

Your regular wallpaper is untouched underneath.

## Customize

All the knobs live in the `CONFIG` block at the top of `starfield.html`: star counts per layer, drift speed and direction, twinkle amount, shooting-star frequency, and the star color palette. After editing, restart the app — no recompile needed.

## Start at login

Edit `com.juniortorres.starfield.plist` so the path in `ProgramArguments` points at your compiled binary, then:

```sh
cp com.juniortorres.starfield.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.juniortorres.starfield.plist
```

To disable: `launchctl unload ~/Library/LaunchAgents/com.juniortorres.starfield.plist` and delete the plist.
