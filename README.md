# nirinit

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
  inputs.nirinit = {
    url = "github:amaanq/nirinit";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # In your NixOS configuration:
  imports = [ nirinit.nixosModules.nirinit ];

  services.nirinit.enable = true;

  # In your Home Manager configuration:
  imports = [ nirinit.homeModules.nirinit ];

  services.nirinit.settings.skip.apps = [ "discord" "firefox" ];
}
```

### Manual

```bash
cargo install --path .

# Run as systemd user service or manually
nirinit --save-interval 300
```

## Configuration

The config file is located at : `$XDG_CONFIG_HOME/nirinit/config.toml`
(for most users this would be `~/.config/nirinit/config.toml`)

```toml
[skip]
apps = ["discord", "slack"]
```

## Session file

The session file is located at `$XDG_DATA_HOME/nirinit/session.json`
(again, for most users this would be `~/.local/share/nirinit/session.json`)

Normally, you shouldn't need to touch this, but if you notice something odd happening
when your session is being restored, deleting this file might help.

## License

MPL-2.0
