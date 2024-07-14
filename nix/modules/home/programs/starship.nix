{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.starship = {
      enable = config.my.roles.terminal.enable;
      settings = pkgs.lib.importTOML "${config.my.configDir}/starship/starship.toml";
    };
  };
}
