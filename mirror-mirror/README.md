# Mirror Mirror

Mirror one monitor to another using `wl-mirror` on Hyprland, Sway, and Niri.

## Features

- Bar icon opens a panel for monitor selection.
- Select source monitor and destination monitor from detected connected outputs.
- Starts `wl-mirror` in fullscreen destination mode so the source is scaled to destination.
- Stop mirroring from the same panel.
- If fewer than 2 monitors are detected, or monitor discovery fails, monitor selectors and mirror actions are disabled; only **Refresh outputs** remains available.

## Dependencies

Install the following package:

- `wl-mirror`

For monitor discovery, the plugin tries one of:

- `wlr-randr` (preferred)
- `hyprctl`
- `swaymsg`
- `niri`

## Usage

1. Add the plugin to the bar.
2. Click the plugin icon.
3. Choose source and destination monitors.
4. Click **Start mirror**.
5. Click **Stop mirror** to end mirroring.

If monitor discovery fails (or only one monitor is detected), use **Refresh outputs** after fixing backend/monitor availability.

### Backend fallback errors

`wl-mirror` may try multiple capture backends. Mirror Mirror only shows a backend error when startup fails overall (no compatible backend worked), and does not show errors for intermediate fallback attempts.

