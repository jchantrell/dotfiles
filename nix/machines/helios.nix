{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./base.nix
  ];

  networking.hostName = "helios";
  system.stateVersion = "23.11";

  systemd.tmpfiles.rules = [
    "d /home/${username}/.config 0755 ${username} users"
    "d /home/${username}/.config/nvim 0755 ${username} users"
  ];

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXboNrsbtK6VjUc7+4y46/3zxmNFM9FtYCQhdhUmhEN"
    ];
  };

  home-manager.users.${username} = {
    imports = [
      ../programs/dev.nix
    ];
  };

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    defaultUser = username;
    startMenuLaunchers = true;
    docker-desktop.enable = false;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
}
