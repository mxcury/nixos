{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    extraConfig = ''
      text-color=#ECEFF4
      border-color=#88C0D0
      default-timeout=5000
    '';
  };
}
