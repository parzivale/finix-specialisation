{
  config,
  lib,
  finixSystem,
  ...
}:
let
  cfg = config.finix-specialisation;
  finixSys = finixSystem {
    inherit lib;
    modules = cfg.modules;
  };
  topLevel = finixSys.config.system.topLevel;
in
{
  options.finix-specialisation = {
    enable = lib.mkEnableOption "finix as a NixOS specialisation";

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
        message = "finix-specialisation: the NixOS host must have boot.bootspec.enable = true";
      }
      {
        assertion = finixSys.config.boot.bootspec.enable;
        message = "finix-specialisation: the finix system must have boot.bootspec.enable = true";
      }
    ];

    system.systemBuilderCommands = lib.mkAfter ''
      ln -s ${topLevel} $out/specialisation/${cfg.specialisationName}
    '';
  };
}
