{
  description = "NixOS module for booting finix alongside NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    finix-flake.url = "github:parzivale/finix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, system, ... }:
        let
          testVm = inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              inputs.self.nixosModules.default
              "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
              (
                { pkgs, ... }:
                {
                  boot.bootspec.enable = true;
                  finix-specialisation.enable = true;
                  finix-specialisation.modules = [ { nixpkgs.pkgs = pkgs; } ];

                  users.users.root.password = "";

                  boot.loader.systemd-boot.enable = true;
                  boot.loader.efi.canTouchEfiVariables = true;
                  boot.loader.timeout = 10;
                  virtualisation.useEFIBoot = true;
                  virtualisation.directBoot.enable = false;

                  fileSystems."/" = {
                    device = "/dev/vda";
                    fsType = "ext4";
                  };

                  system.stateVersion = "24.11";
                }
              )
            ];
          };
        in
        {
          formatter = pkgs.nixfmt-tree;

          packages.test-vm = testVm.config.system.build.vm;

          checks = {
            specialisation-exists = pkgs.callPackage ./tests/specialisation-exists.nix {
              nixpkgs = inputs.nixpkgs;
              finixModule = inputs.self.nixosModules.default;
            };

            vm = pkgs.callPackage ./tests/vm.nix {
              nixpkgs = inputs.nixpkgs;
              finixModule = inputs.self.nixosModules.default;
            };
          };
        };

      flake = {
        nixosModules.default = {
          imports = [ ./module ];
          _module.args.finixSystem = inputs.finix-flake.lib.finixSystem;
        };
      };
    };
}
