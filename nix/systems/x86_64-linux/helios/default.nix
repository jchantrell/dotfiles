{ pkgs, ... }:
let
  user = "joel";
in
{
  imports = [ ./hardware.nix ];

  time.timeZone = "Australia/Adelaide";

  networking = {
    hostName = "helios";
    networkmanager.enable = true;
  };

  programs.zsh.enable = true;
  programs.dconf.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    description = "personal profile";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXboNrsbtK6VjUc7+4y46/3zxmNFM9FtYCQhdhUmhEN"
    ];
  };

  security.rtkit.enable = true;

  systemd.tmpfiles.rules = [
    "d /home/${user}/.config 0755 ${user} users"
    "d /home/${user}/.config/nvim 0755 ${user} users"
  ];
}
