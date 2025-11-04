{ config, pkgs, ... }:

{
  imports = [
    ./scripts/rofi/launchers.nix
  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "JetBrainsMono Nerd Font Propo 12";

    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
      display-drun = "  Apps";
      display-run = "  Run";
      display-window = "  Windows";
      terminal = "kitty";
      matching = "fuzzy";
    };

    theme = ''
      * {
        font: "JetBrainsMono Nerd Font Propo 12";
        
        /* Catppuccin Mocha palette */
        base:      #1e1e2e;
        mantle:    #181825;
        crust:     #11111b;
        text:      #cdd6f4;
        subtext0:  #a6adc8;
        subtext1:  #bac2de;
        overlay0:  #6c7086;
        overlay1:  #7f849c;
        surface0:  #313244;
        surface1:  #45475a;
        surface2:  #585b70;
        accent:    #89b4fa;
        blue:      #89b4fa;
        green:     #a6e3a1;
        yellow:    #f9e2af;
        red:       #f38ba8;
        
        background-color: transparent;
        text-color: @text;
      }

      window {
        location: center;
        width: 600px;
        border: 2px solid;
        border-color: @accent;
        background-color: @base;
        padding: 12px;
      }

      mainbox {
        border: 1px dashed;
        border-color: @surface1;
        padding: 8px;
        spacing: 8px;
        children: [inputbar, message, listview, mode-switcher];
      }

      inputbar {
        border: 1px solid;
        border-color: @surface2;
        padding: 6px;
        background-color: @mantle;
        spacing: 8px;
        children: [prompt, entry];
      }

      prompt {
        text-color: @accent;
        background-color: @mantle;
      }

      entry {
        placeholder: "Type to search...";
        placeholder-color: @overlay0;
        background-color: @mantle;
        text-color: @text;
      }

      listview {
        border: 1px solid;
        border-color: @surface1;
        padding: 4px;
        lines: 10;
        columns: 1;
        fixed-height: false;
        scrollbar: false;
      }

      element {
        padding: 6px 8px;
        spacing: 8px;
        border: 1px solid transparent;
      }

      element normal.normal {
        background-color: @base;
        text-color: @subtext0;
      }

      element normal.active {
        background-color: @base;
        text-color: @accent;
      }

      element alternate.normal {
        background-color: @surface0;
        text-color: @subtext0;
      }

      element alternate.active {
        background-color: @surface0;
        text-color: @accent;
      }

      element selected.normal {
        background-color: @accent;
        text-color: @base;
        border-color: @accent;
      }

      element selected.active {
        background-color: @accent;
        text-color: @base;
        border-color: @accent;
      }

      element-icon {
        size: 1.2em;
        vertical-align: 0.5;
      }

      element-text {
        vertical-align: 0.5;
      }

      message {
        border: 1px solid;
        border-color: @surface1;
        padding: 6px;
        background-color: @mantle;
      }

      textbox {
        text-color: @text;
      }

      mode-switcher {
        border: 1px solid;
        border-color: @surface1;
        background-color: @mantle;
        padding: 4px;
        spacing: 8px;
      }

      button {
        padding: 4px 8px;
        border: 1px solid transparent;
        background-color: @mantle;
        text-color: @subtext0;
      }

      button selected {
        border: 1px dashed;
        border-color: @accent;
        text-color: @accent;
        background-color: @surface0;
      }
    '';
  };
}
