{ inputs, ... }:
{
  imports = [
    ../common
    inputs.nix-index-database.hmModules.nix-index
  ];
}
