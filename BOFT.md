# Boft's RustDesk build

RustDesk 1.5.3 for Boft's photo terminals (Windows x64), built by `.github/workflows/boft-windows.yml` (manual runs).
Branch `boft-1.5.3` = tag 1.5.3 (95cca3f) + Boft's commits; upstream's own workflows are removed on this branch.

Why a build of our own: Privacy mode that survives a short drop, the connection window and tray icon hidden, and the
server built in (custom-client config signed with our key). AGPL-3.0, as upstream: this branch is the source.

Changes:
- `src/ipc.rs`: `hide_cm` answers without the Pro/custom-client gate, so the connection window can be hidden
  (still needs approve mode password, permanent password only and `allow-hide-cm` = Y).
- `src/common.rs`: `KEY` in `read_custom_client` is ours. `boft/custom.txt` (from `boft/custom.json` by
  `boft/sign-custom.sh <key>`) is built into the binary (`include_str!` in `load_custom_client`; a
  `custom.txt` next to `rustdesk.exe` made the service's `--server` loop, and is now ignored), and `core_main`
  logs whether it loaded: tray icon hidden, settings locked (command-line
  settings still allowed), auto-update off; our server and key as defaults. **No `app-name`**: the name builds the
  config file names, so it stays "RustDesk" and every terminal keeps its ID and password.
- `src/privacy_mode.rs`, `src/privacy_mode/win_topmost_window.rs`, `src/server/connection.rs`: **Privacy mode
  grace.** When the connection that owns privacy mode drops (any close but the viewer's own, the connection manager,
  auto disconnect and the like), the cover and the input block stay for 120 s (`BOFT_GRACE_SECS`). A remote login
  meanwhile is let in and takes privacy mode over at authorization (its viewer is told it is on); so does a login from
  the owner's viewer ID while the old link has not timed out yet. Nobody back in 120 s: privacy mode goes off. Only the
  topmost-window implementation (exclude-from-capture and magnifier, i.e. Privacy mode 1) hands over; the others keep
  stock behaviour.
