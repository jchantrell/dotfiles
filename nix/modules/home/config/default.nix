{
  config,
  lib,
  pkgs,
  nixosConfig ? null,
  ...
}:
{
  options.my = {
    configDir = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = nixosConfig.my.configDir or "${config.home.homeDirectory}/nix";
      description = "Location of the nix config directory (this repo)";
    };

    configType = lib.mkOption {
      type = lib.types.str;
      default = if config.my.isNixos then "nixos" else "standalone";
    };

    isNixos = lib.mkOption {
      type = lib.types.bool;
      default = nixosConfig != null;
      readOnly = true;
    };
  };

  config = {
    programs.home-manager.enable = true;
    home.stateVersion = "24.11";
    home.sessionVariables.FLAKE = config.my.configDir;

    programs.gpg.enable = true;
    programs.dircolors.enable = true;

    services.network-manager-applet.enable = pkgs.stdenv.isLinux;

    nix.gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
