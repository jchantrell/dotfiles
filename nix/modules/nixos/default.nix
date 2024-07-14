{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../common
  ] ++ lib.snowfall.fs.get-non-default-nix-files ./.;

  options = {
    my.configDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      apply = toString;
      description = "Location of the nix config directory (this repo)";
    };
  };
  

  config = {
    system.stateVersion = "24.11";
    hardware.enableAllFirmware = true;
    home-manager = {
	    backupFileExtension = "hm.old";

	    useGlobalPkgs = true;
	    useUserPackages = true;

    };

    environment.pathsToLink = ["/share/zsh"];
    environment.shells = [pkgs.zsh];
    environment.enableAllTerminfo = true;
    security.sudo.wheelNeedsPassword = false;

    nix = {
      optimise.automatic = true;
      gc = {
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    console = {
      keyMap = lib.mkDefault "en";
      earlySetup = true;
    };

    services.openssh.enable = true;

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Support for dynamic linking in NixOS
    # programs.nix-ld.enable = true;
  };
}
