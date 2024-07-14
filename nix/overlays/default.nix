{
  nur,
  neovim-nightly-overlay,
  nixd,
  ...
}:
self: super:
{
  nur = import nur {
    pkgs = super;
    nurpkgs = super;
  };
}
// (neovim-nightly-overlay.overlays.default self super)
// (nixd.overlays.default self super)
