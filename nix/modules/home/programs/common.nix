{
  config,
  lib,
  pkgs,
  ...
}:
let
  packages = with pkgs; [
    bat
    cmake
    bottom
    coreutils
    curl
    devenv
    du-dust
    fd
    findutils
    fswatch
    fx
    fzf
    gcc
    git
    git-crypt
    gnumake
    htop
    jq
    killall
    mosh
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

    # languages
    rustup
    go
    lua
    nodejs
    bun
    python3
    typescript

    # lsps
    ccls # c / c++
    gopls # go
    nodePackages.typescript-language-server # typescript
    nodePackages."@astrojs/language-server" # astro
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server # yaml
    lua-language-server # lua
    nil # nix
    nixd # nix
    pyright # python

    # formatters
    statix # nix
    deadnix # nix
    nixfmt-rfc-style # nix
    black # python
    ruff # python
    isort # python
    golangci-lint # go
    lua52Packages.luacheck # lua
    stylua # lua
    shellcheck # shell
    shfmt # shell
    sqlfluff # sql
    tflint # terraform
    prettierd # fast prettier
    biome # prettier alternative

    # misc
    nodePackages.pnpm # npm alternative
    cargo-cache # rust packages
    cargo-expand # rust packages
    mkcert # certs
    httpie # api testing
    gh # github
    just # command recipes
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

    };

    home.file.".ssh/allowed_signers".text = "* ${builtins.readFile /home/joel/.ssh/id_ed25519.pub}";

    home.packages = packages ++ [
      # pkgs.some-package
    ];
  };
}
