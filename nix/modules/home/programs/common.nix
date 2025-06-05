{
  config,
  lib,
  pkgs,
  ...
}:
let
  packages = with pkgs; [

    # languages
    rustup
    go
    lua
    nodejs
    bun
    python3
    typescript

    # lsps
    ccls
    gopls
    nodePackages.typescript-language-server
    nodePackages."@astrojs/language-server"
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    lua-language-server
    nil
    nixd
    pyright

    # formatters
    statix
    deadnix
    nixfmt-rfc-style
    black
    ruff
    isort
    golangci-lint
    lua52Packages.luacheck
    stylua
    shellcheck
    shfmt
    sqlfluff
    tflint
    prettierd
    biome

    # misc
    bat
    cmake
    bottom
    cargo-cache
    cargo-expand
    just
    coreutils
    curl
    devenv
    du-dust
    esbuild
    fd
    findutils
    fswatch
    fx
    fzf
    gcc
    gh
    git
    git-crypt
    gnumake
    htop
    httpie
    imagemagick
    jq
    killall
    mkcert
    mosh
    nodePackages.pnpm
    procs
    ripgrep
    sd
    sqlite
    tree
    tree-sitter
    unzip
    vim
    wget
    zip
  ];
in
{
  config = lib.mkIf config.my.roles.terminal.enable {
    programs = {
      nix-index.enable = true;
      nix-index.enableZshIntegration = true;
      nix-index-database.comma.enable = true;

      fzf.enable = true;
      fzf.enableZshIntegration = true;

      lsd.enable = true;
      lsd.enableAliases = true;

      zoxide.enable = true;
      zoxide.enableZshIntegration = true;

      broot.enable = true;
      broot.enableZshIntegration = true;

      direnv.enable = true;
      direnv.enableZshIntegration = true;
      direnv.nix-direnv.enable = true;

      wezterm.enable = true;
    };

    home.file.".ssh/allowed_signers".text = "* ${builtins.readFile /home/joel/.ssh/id_ed25519.pub}";

    home.sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.lib.makeLibraryPath packages}";
    };

    home.packages = packages ++ [
      pkgs.imagemagick
      pkgs.stdenv.cc.cc.lib
    ];
  };
}
