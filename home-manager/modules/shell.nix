{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -l";
      la = "eza -la";
      cat = "bat";
      grep = "rg";
      find = "fd";
      nix-rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nixos#nixpad";
      nix-list = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
      nix-clean = "sudo nix-collect-garbage -d";
    };

    initContent = ''
      setopt AUTO_CD
      setopt HIST_IGNORE_DUPS
      setopt SHARE_HISTORY
    '';

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
  };

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
}
