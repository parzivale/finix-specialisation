{
  description = "NixOS module for booting finix alongside NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    finix-flake.url = "github:parzivale/finix";
  };

  outputs =
    {
      self,
      nixpkgs,
      finix-flake,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forSystems =
        fn:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = fn system;
          }) systems
        );

      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      formatter = forSystems (system: (pkgsFor system).nixfmt-tree);

      nixosModules.default = {
        imports = [ ./module ];
        _module.args.finixSystem = finix-flake.lib.finixSystem;
      };
    };
}
