{
  description = "nirinit";

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
        nirinit =
          { config, pkgs, ... }:
          let
            inherit (lib)
              mkEnableOption
              mkPackageOption
              mkIf
              getExe
              ;
            cfg = config.services.nirinit;
          in
          {
            options = {
              services.nirinit = {
                enable = mkEnableOption "Niri Sessions";
                package = mkPackageOption self.packages.${pkgs.system} "nirinit" { };
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
                  description = "Configuration for nirinit";
                };
              };
            };
            config = mkIf cfg.enable {
              systemd.user.services.nirinit = {
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
        nirinit =
          { config, pkgs, ... }:
          let
            inherit (lib) mkIf;
            cfg = config.services.nirinit;
          in
          {
            config = mkIf cfg.enable {
              xdg.configFile."nirinit/config.toml" = {
                source = (pkgs.formats.toml { }).generate "nirinit-config.toml" cfg.settings;
              };
            };
          };
      };

      packages = eachSystem (
        system:
        let
          pkgs = pkgsFor.${system};
          packageName = "nirinit";
        in
        {
          nirinit = pkgs.rustPlatform.buildRustPackage {
            pname = packageName;
            src = ./.;
            version = "0.1.2";

            cargoLock.lockFile = ./Cargo.lock;

            meta.mainProgram = packageName;
          };

          default = self.packages.${system}.nirinit;
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
