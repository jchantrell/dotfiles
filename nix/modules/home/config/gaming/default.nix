{
  lib,
  pkgs,
  config,
  nixosConfig ? null,
  ...
}:
{
  options.my.roles.gaming.enable = lib.mkOption {
    default = nixosConfig.my.roles.gaming.enable or false;
    description = "Enable gaming-related packages and configuration";
  };

  config = lib.mkIf config.my.roles.gaming.enable {
    home.packages = [
      pkgs.discord
      pkgs.gamehub
      pkgs.protonup-qt
      pkgs.lutris
    ];

    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
    };

    xdg.desktopEntries."Steam Linux Runtime 3.0 (sniper).desktop".noDisplay = true;
  };
}
