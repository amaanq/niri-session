# niri-session

Session manager for [Niri](https://github.com/YaLTeR/niri) that automatically saves
and restores your window layout.

## Features

- Auto-saves session every 5 minutes (configurable)
- Restores windows to their workspaces on startup
- Preserves workspace names, indices, and outputs
- Skip apps from being restored

## Installation

### NixOS + Home Manager

```nix
{
  inputs.niri-session = {
    url = "github:amaanq/niri-session";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # In your NixOS configuration:
  imports = [ niri-session.nixosModules.niri-session ];

  services.niri-session.enable = true;

  # In your Home Manager configuration:
  imports = [ niri-session.homeManagerModules.niri-session ];

  services.niri-session.settings.skip.apps = [ "discord" "firefox" ];
}
```

### Manual

```bash
cargo install --path .

# Run as systemd user service or manually
niri-session --save-interval 300
```

## Configuration

The config file is located at : `$XDG_CONFIG_HOME/niri-session/config.toml`
(for most users this would be `~/.config/niri-session/config.toml`)

```toml
[skip]
apps = ["discord", "slack"]
```

## Session file

The session file is located at `$XDG_DATA_HOME/niri-session/session.json`
(again, for most users this would be `~/.local/share/niri-session/session.json`)

Normally, you shouldn't need to touch this, but if you notice something odd happening
when your session is being restored, deleting this file might help.

## License

MPL-2.0
