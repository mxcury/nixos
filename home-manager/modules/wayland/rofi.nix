
{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    font = "JetBrainsMono Nerd Font Propo 12";

    extraConfig = {
      modi = "  drun,   run,   window";
      show-icons = false;
      show-mode = true;
      lines = 10;
      columns = 1;
      terminal = "kitty";
      matching = "fuzzy";
      prompt = "  Run  ";
    };

    theme = ''
      * {
        font: "JetBrainsMono Nerd Font Propo 12";
        border: 1px;
        border-radius: 0;
        padding: 4px;
        spacing: 2;
        background-color: @base;
        foreground: @text;
        selected-background: @accent;
        selected-foreground: @base;
      }

      /* === Catppuccin Mocha palette === */
      @define-color base      #1e1e2e;
      @define-color mantle    #181825;
      @define-color crust     #11111b;
      @define-color text      #cdd6f4;
      @define-color subtext0  #a6adc8;
      @define-color overlay0  #6c7086;
      @define-color surface0  #313244;
      @define-color surface1  #45475a;
      @define-color surface2  #585b70;
      @define-color accent    #89b4fa;

      window {
        border: 2px;
        border-color: @accent;
        padding: 8px;
        background-color: @base;
      }

      mainbox {
        border: 1px dashed @surface1;
        padding: 6px;
        spacing: 6px;
      }

      inputbar {
        border: 1px solid @surface2;
        padding: 4px;
        background-color: @mantle;
        text-color: @text;
      }

      prompt {
        text-color: @accent;
        background-color: @mantle;
        margin: 0 6px 0 0;
      }

      entry {
        background-color: @mantle;
        text-color: @text;
        placeholder: "Type to search…";
      }

      listview {
        scrollbar: false;
        fixed-height: false;
        border: 1px solid @surface1;
      }

      element {
        padding: 2px 4px;
        background-color: transparent;
        text-color: @subtext0;
      }

      element selected {
        background-color: @accent;
        text-color: @base;
      }

      element alternate {
        background-color: @surface0;
      }

      message {
        border: 1px solid @surface1;
        padding: 4px;
        text-color: @overlay0;
      }

      mode-switcher {
        border: 1px solid @surface1;
        background-color: @mantle;
        text-color: @subtext0;
        padding: 2px;
        spacing: 8px;
        border-radius: 0;
        horizontal-align: 0.5;
      }

      button {
        border: 1px solid transparent;
        padding: 2px 4px;
      }

      button selected {
        border: 1px dashed @accent;
        text-color: @accent;
      }
    '';
  };
}
