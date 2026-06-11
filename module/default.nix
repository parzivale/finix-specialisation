{
  config,
  lib,
  ...
}:
let
  cfg = config.finix-specialisation;
  finixSys = cfg.finixSystem { modules = cfg.modules; };
  topLevel = finixSys.config.system.topLevel;
in
{
  options.finix-specialisation = {
    enable = lib.mkEnableOption "finix as a NixOS specialisation";

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
      description = "Finix modules to build as the specialisation.";
    };

    specialisationName = lib.mkOption {
      type = lib.types.str;
      default = "finix";
      description = ''
        Name of the specialisation under the NixOS toplevel's
        `specialisation/` directory. This is what the bootloader uses
        as the entry label.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.boot.bootspec.enable;
        message = "finix-entry: the NixOS host must have boot.bootspec.enable = true";
      }
      {
        assertion = finixSys.config.boot.bootspec.enable;
        message = "finix-entry: the finix system must have boot.bootspec.enable = true";
      }
    ];

    system.systemBuilderCommands = ''
      ln -s ${topLevel} $out/specialisation/${cfg.specialisationName}
    '';
  };
}
