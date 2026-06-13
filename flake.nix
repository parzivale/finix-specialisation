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
                { pkgs, finixModules, ... }:
                {
                  boot = {
                    bootspec.enable = true;
                    loader = {
                      systemd-boot.enable = true;
                      efi.canTouchEfiVariables = true;
                      timeout = 10;
                    };
                  };
                  finix-specialisation.enable = true;
                  finix-specialisation.modules = [
                    "${inputs.finix-flake}/modules/virtualisation/qemu.nix"
                    finixModules.getty
                    finixModules.sysklogd
                    { nixpkgs.pkgs = pkgs; }
                    {
                      boot.initrd.kernelModules = [ "virtio_gpu" ];
                      services.sysklogd.enable = true;
                      fileSystems."/" = {
                        device = "tmpfs";
                        fsType = "tmpfs";
                        options = [ "mode=755" ];
                      };
                      users.users.root.password = "";
                    }
                  ];

                  users.users.root.password = "";
                  virtualisation = {
                    useEFIBoot = true;
                    useBootLoader = true;
                    mountHostNixStore = true;
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
              inherit (inputs) nixpkgs;
              finixModule = inputs.self.nixosModules.default;
            };

            vm = pkgs.callPackage ./tests/vm.nix {
              inherit (inputs) nixpkgs;
              finixModule = inputs.self.nixosModules.default;
            };
          };
        };

      flake = {
        nixosModules.default = {
          imports = [ ./module ];
          _module.args.finixSystem = inputs.finix-flake.lib.finixSystem;
          _module.args.finixModules = inputs.finix-flake.nixosModules;
        };
      };
    };
}
