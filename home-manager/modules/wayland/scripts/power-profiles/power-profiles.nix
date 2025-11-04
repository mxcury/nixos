{ config, pkgs, ... }:
{
  imports = [
    ./power-profile.nix
    ./power-profile-toggle.nix
  ];
}
