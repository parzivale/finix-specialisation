{
  description = "NixOS module for booting finix alongside NixOS";

  outputs =
    { self }:
    let
      sources = import ./lon.nix;

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

      pkgsFor = system: import sources.nixpkgs { inherit system; };
    in
    {
      formatter = forSystems (system: (pkgsFor system).nixfmt-tree);

      nixosModules.default = ./module;
      nixosModules.finix-entry = ./module;
    };
}
