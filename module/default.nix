{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.finix-entry;
  finixSys = cfg.finixSystem { modules = cfg.modules; };
  topLevel = finixSys.config.system.topLevel;
in
{
  options.finix-entry = {
    enable = lib.mkEnableOption "finix as a NixOS system profile";

    finixSystem = lib.mkOption {
      type = lib.types.raw;
      description = ''
        The `lib.finixSystem` function from finix-flake.
        Pass `inputs.finix-flake.lib.finixSystem`.
      '';
    };

    modules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
      description = "Finix modules to build as the system profile.";
    };

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "finix";
      description = ''
        Name of the profile under `/nix/var/nix/profiles/system-profiles/`.
        This is what the bootloader uses as the entry label.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = finixSys.config.boot.bootspec.enable;
        message = "finix-entry: the finix system must have boot.bootspec.enable = true";
      }
    ];

    # Register the finix system as a NixOS system profile so that any
    # NixOS bootloader (limine, grub, systemd-boot) discovers it via
    # /nix/var/nix/profiles/system-profiles/ and generates a boot entry
    # from the finix bootspec. Profiles in that directory are GC roots.
    system.activationScripts.finix-entry = {
      deps = [ "nix" ];
      text = ''
        mkdir -p /nix/var/nix/profiles/system-profiles
        ${pkgs.nix}/bin/nix-env \
          --profile /nix/var/nix/profiles/system-profiles/${cfg.profileName} \
          --set ${topLevel}
      '';
    };
  };
}
