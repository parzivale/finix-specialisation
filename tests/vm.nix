# VM test: boots a NixOS system with finix-specialisation enabled and
# checks the specialisation symlink and bootspec are present at runtime.
{
  pkgs,
  nixpkgs,
  finixModule,
}:
pkgs.testers.nixosTest {
  name = "finix-specialisation";

  nodes.machine =
    { ... }:
    {
      imports = [ finixModule ];

      boot.bootspec.enable = true;
      finix-specialisation.enable = true;
      finix-specialisation.modules = [ { nixpkgs.pkgs = pkgs; } ];

      virtualisation.memorySize = 1024;
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    # specialisation symlink must exist
    machine.succeed("test -L /run/current-system/specialisation/finix")

    # bootspec must be present and contain the v1 schema key
    machine.succeed(
      "grep -q 'org.nixos.bootspec.v1' /run/current-system/specialisation/finix/boot.json"
    )

    machine.shutdown()
  '';
}
