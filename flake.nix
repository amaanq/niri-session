{
  description = "niri-session";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (inputs) self;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      eachSystem = lib.genAttrs systems;
      pkgsFor = inputs.nixpkgs.legacyPackages;
    in
    {
      nixosModules = {
        niri-session =
          { config, pkgs, ... }:
          let
            inherit (lib)
              mkEnableOption
              mkPackageOption
              mkIf
              getExe
              ;
            cfg = config.services.niri-session;
          in
          {
            options = {
              services.niri-session = {
                enable = mkEnableOption "Niri Sessions";
                package = mkPackageOption self.packages.${pkgs.system} "niri-session" { };
                settings = lib.mkOption {
                  type = lib.types.submodule {
                    freeformType = (pkgs.formats.toml { }).type;
                    options = {
                      skip = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
                            apps = lib.mkOption {
                              type = lib.types.listOf lib.types.str;
                              default = [ ];
                              description = "List of app IDs to skip during session restore";
                            };
                          };
                        };
                        default = { };
                        description = "Applications to skip";
                      };
                    };
                  };
                  default = { };
                  description = "Configuration for niri-session";
                };
              };
            };
            config = mkIf cfg.enable {
              systemd.user.services.niri-session = {
                enable = true;
                description = "Niri Sessions";
                wantedBy = [ "graphical-session.target" ];
                partOf = [ "graphical-session.target" ];
                wants = [ "graphical-session.target" ];
                after = [ "graphical-session.target" ];
                serviceConfig = {
                  Type = "simple";
                  Restart = "always";
                  ExecStart = "${getExe cfg.package}";
                  PrivateTmp = true;
                };
              };
            };
          };
      };

      homeManagerModules = {
        niri-session =
          { config, pkgs, ... }:
          let
            inherit (lib) mkIf;
            cfg = config.services.niri-session;
          in
          {
            config = mkIf cfg.enable {
              xdg.configFile."niri-session/config.toml" = {
                source = (pkgs.formats.toml { }).generate "niri-session-config.toml" cfg.settings;
              };
            };
          };
      };

      packages = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          packageName = "niri-session";
        in
        {
          niri-session = pkgs.rustPlatform.buildRustPackage {
            pname = packageName;
            src = ./.;
            version = "0.1.1";

            cargoLock.lockFile = ./Cargo.lock;

            meta.mainProgram = packageName;
          };

          default = self.packages.${system}.niri-session;
        }
      );

      devShells = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = builtins.attrValues {
              inherit (pkgs)
                cargo
                clippy
                rustc
                rust-analyzer
                rustfmt

                nixfmt-rfc-style
                ;
            };
          };
        }
      );
    };
}
