{
  config,
  lib,
  pkgs,
  ...
}:
let
  nvimDir = "${config.my.configDir}/nvim";
in
{
  config = lib.mkIf config.my.roles.terminal.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      plugins = [
        pkgs.vimPlugins.lazy-nvim
      ];
    };

    xdg.configFile = {
      "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/lazy-lock.json";

      "nvim/init.lua".text = # lua
        ''
          package.path = package.path .. ";${config.home.homeDirectory}/.config/nvim/nix/?.lua"

          vim.g.gcc_bin_path = '${lib.getExe pkgs.gcc}'
	  vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.${
            if pkgs.stdenv.isDarwin then "dylib" else "so"
          }'

          require("config")
        '';

      "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${nvimDir}/config/lua";

      "${config.my.configDir}/.nixd.json".text = builtins.toJSON {
        options = {
          enable = true;
          target.installable = ".#homeConfigurations.nixd.options";
        };
      };
    };

    home.activation.neovim =
      lib.home-manager.hm.dag.entryAfter [ "linkGeneration" ] # bash
        ''
          LOCK_FILE=$(readlink -f ~/.config/nvim/lazy-lock.json)
          echo $LOCK_FILE
          [ ! -f "$LOCK_FILE" ] && echo "No lock file found, skipping" && exit 0

          STATE_DIR=~/.local/state/nix/
          STATE_FILE=$STATE_DIR/lazy-lock-checksum

          [ ! -d $STATE_DIR ] && mkdir -p $STATE_DIR
          [ ! -f $STATE_FILE ] && touch $STATE_FILE

          HASH=$(nix-hash --flat $LOCK_FILE)

          if [ "$(cat $STATE_FILE)" != "$HASH" ]; then
            echo "Syncing neovim plugins"
            $DRY_RUN_CMD ${config.programs.neovim.finalPackage}/bin/nvim --headless "+Lazy! restore" +qa
            $DRY_RUN_CMD echo $HASH >$STATE_FILE
          else
            $VERBOSE_ECHO "Neovim plugins already synced, skipping"
          fi
        '';
  };
}
