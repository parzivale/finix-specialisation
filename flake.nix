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

      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt-tree;
      };

      flake = {
        nixosModules.default = {
          imports = [ ./module ];
          _module.args.finixSystem = inputs.finix-flake.lib.finixSystem;
        };
      };
    };
}
