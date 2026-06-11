# Build-time check: verifies the specialisation symlink and bootspec are
# present in the NixOS toplevel after evaluation. No VM required.
{
  pkgs,
  nixpkgs,
  finixModule,
}:
let
  nixos = nixpkgs.lib.nixosSystem {
    inherit (pkgs.stdenv) system;
    modules = [
      finixModule
      {
        boot.bootspec.enable = true;
        finix-specialisation.enable = true;
        finix-specialisation.modules = [ { nixpkgs.pkgs = pkgs; } ];

        fileSystems."/" = {
          device = "tmpfs";
          fsType = "tmpfs";
        };
        boot.loader.grub.enable = false;
        system.stateVersion = "24.11";
      }
    ];
  };
in
pkgs.runCommand "specialisation-exists" { } ''
  toplevel=${nixos.config.system.build.toplevel}

  test -L "$toplevel/specialisation/finix" \
    || { echo "FAIL: specialisation/finix symlink missing"; exit 1; }

  target=$(readlink -f "$toplevel/specialisation/finix")

  test -f "$target/boot.json" \
    || { echo "FAIL: boot.json missing in finix toplevel"; exit 1; }

  echo "OK: specialisation/finix -> $target"
  touch $out
''
