#! /usr/bin/env nix-shell
#! nix-shell -i bash -p patchelf

sudo nixos-rebuild switch --flake . --impure
