{
  pkgs,
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = [ pkgs.git-crypt ];
    programs.git = {
      enable = true;
      userEmail = "joelchantrell@protonmail.com";
      userName = "Joel Chantrell";
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      lfs.enable = true;
      ignores = [
        ".aws"
        ".direnv"
        ".env"
        ".envrc"
        ".lsp.lua"
        ".venv"
        ".vim"
        "__pycache__"
        "target"
        "tmp"
        "typings"
      ];
      extraConfig = {
        pull.rebase = "true";
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
          tool = "vimdiff";
          log = true;
        };
        diff = {
          colorMoved = "default";
          tool = "difftastic";
          renames = true;
          mnemonicPrefix = true;
        };
        difftool = {
          prompt = false;
          difftastic.cmd = "${lib.getExe pkgs.difftastic} $LOCAL $REMOTE";
        };
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        user.signingkey = "~/.ssh/id_ed25519.pub";
        grep.extendedRegexp = true;
      };
    };
  };
}
