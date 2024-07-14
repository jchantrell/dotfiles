{ ... }:
{
  pre-commit.hooks = {
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    check-symlinks.enable = true;
    detect-aws-credentials.enable = true;
    detect-private-keys.enable = true;
    end-of-file-fixer.enable = true;
    ripsecrets.enable = true;
    trim-trailing-whitespace.enable = true;

    gofmt.enable = true;
    actionlint.enable = true;
    pyright.enable = true;
    shfmt.enable = true;
    stylua.enable = true;
    tflint.enable = true;

    nixfmt-rfc-style = {
      enable = true;
      files = "\\.nix$";
      entry = "nixfmt";
    };
    prettierd = {
      enable = false;
      files = "\\.(jsx?|tsx?|c(js|ts)|m(js|ts)|d\\.(ts|cts|mts)|jsonc?|css)$";
      entry = "prettierd";
    };
    biome = {
      enable = true;
      files = "\\.(jsx?|tsx?|c(js|ts)|m(js|ts)|d\\.(ts|cts|mts)|jsonc?|css)$";
      entry = "biome check --apply --files-ignore-unknown=true --no-errors-on-unmatched";
    };
  };
}
