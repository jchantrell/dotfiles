#! /usr/bin/env nix-shell
#! nix-shell -i bash -p patchelf

sudo nixos-rebuild switch --flake .

for lang in $(ls ~/.local/share/nvim/mason/packages)
do
  echo Linking $lang...
  path=~/.local/share/nvim/mason/packages/$lang
  ./patchelf.sh $(find $path -type f -executable -print)
done
