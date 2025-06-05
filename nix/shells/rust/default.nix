{ inputs, pkgs, ... }:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  buildInputs = [ pkgs.pkg-config ];
}
