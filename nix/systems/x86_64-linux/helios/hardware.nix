{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [ inputs.nixos-wsl.nixosModules.wsl ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    defaultUser = "joel";
    startMenuLaunchers = true;
    docker-desktop.enable = false;
    usbip = {
      enable = true;
      autoAttach = [ "6-2" ];
    };
  };

  services.pcscd.enable = true;
  services.udev = {
    enable = true;
    packages = [ pkgs.yubikey-personalization ];
    extraRules = ''
      SUBSYSTEM=="usb", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0666"
    '';
  };

  environment.systemPackages = [
    pkgs.linuxPackages.usbip
    pkgs.yubikey-manager
    pkgs.libfido2
  ];

  systemd = {
    services."usbip-auto-attach@" = {
      description = "Auto attach device having busid %i with usbip";
      after = [ "network.target" ];

      scriptArgs = "%i";
      path = [ pkgs.linuxPackages.usbip ];

      script = ''
        busid="$1"
        ip="$(grep nameserver /etc/resolv.conf | cut -d' ' -f2)"

        echo "Starting auto attach for busid $busid on $ip."
      '';
    };

    targets.multi-user.wants = map (
      busid: "usbip-auto-attach@${busid}.service"
    ) config.wsl.usbip.autoAttach;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
}
