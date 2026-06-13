# finix-specialisation

A NixOS module that boots [finix](https://github.com/parzivale/finix) alongside NixOS using the bootspec specialisation mechanism. The finix system appears as a selectable entry in systemd-boot without requiring a separate partition or bootloader installation.

> This project was developed with AI assistance (Claude).

## How it works

The module injects the finix system's `boot.json` bootspec into the NixOS host's `boot.json` under `org.nixos.specialisation.v1`, and creates a `specialisation/finix` symlink in the NixOS toplevel. systemd-boot-builder picks this up and generates a separate boot entry for finix.

## Usage

Add the module to your NixOS flake inputs:

```nix
inputs = {
  finix-specialisation.url = "github:parzivale/finix-specialisation";
  finix-flake.url = "github:parzivale/finix";
};
```

Then import it and configure it in your NixOS system:

```nix
{
  imports = [ inputs.finix-specialisation.nixosModules.default ];

  boot.bootspec.enable = true;

  finix-specialisation.enable = true;
  finix-specialisation.modules = [
    # your finix system modules
    { nixpkgs.pkgs = pkgs; }
  ];
}
```

### Options

| Option | Type | Default | Description |
|---|---|---|---|
| `finix-specialisation.enable` | bool | `false` | Enable the module |
| `finix-specialisation.modules` | list | `[]` | Finix modules to build as the specialisation |
| `finix-specialisation.specialisationName` | str | `"finix"` | Name of the boot entry |

### Requirements

- `boot.bootspec.enable = true` on the NixOS host
- systemd-boot as the bootloader
- `finixModules` is available as a module arg (`inputs.finix-flake.nixosModules`)

## Development

Run the test VM:

```
nix run .#test-vm
```

Run checks:

```
nix flake check
```
