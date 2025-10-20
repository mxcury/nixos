{ config, lib, pkgs, ... }:

{
  # Enable fingerprint sensor for Synaptics 06cb:009a
  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
  };

  # Enable PAM for fingerprint authentication
#  security.pam.services.sudo.fprintAuth = true;
#  security.pam.services.login.fprintAuth = true;

  # Restart fingerprint services after resume from suspend
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart python-validity.service
    ${pkgs.systemd}/bin/systemctl restart open-fprintd.service
    sleep 2
  '';
}
