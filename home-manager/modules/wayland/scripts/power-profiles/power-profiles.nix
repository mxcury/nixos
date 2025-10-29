{ config, pkgs, ... }:
{
  import = [
    ./power-profile.nix
    ./power-profile-toggle.nix
  ];
}
