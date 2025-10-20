{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrains Mono";
      font_size = 11;
      background_opacity = "0.9";
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      
      # Tokyo Night color scheme
      foreground = "#c0caf5";
      background = "#1a1b26";
      selection_foreground = "#c0caf5";
      selection_background = "#33467c";
      
      cursor = "#c0caf5";
      cursor_text_color = "#1a1b26";
      
      url_color = "#73daca";
      
      # Black
      color0 = "#15161e";
      color8 = "#414868";
      
      # Red
      color1 = "#f7768e";
      color9 = "#f7768e";
      
      # Green
      color2 = "#9ece6a";
      color10 = "#9ece6a";
      
      # Yellow
      color3 = "#e0af68";
      color11 = "#e0af68";
      
      # Blue
      color4 = "#7aa2f7";
      color12 = "#7aa2f7";
      
      # Magenta
      color5 = "#bb9af7";
      color13 = "#bb9af7";
      
      # Cyan
      color6 = "#7dcfff";
      color14 = "#7dcfff";
      
      # White
      color7 = "#a9b1d6";
      color15 = "#c0caf5";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
      };
      package = {
        disabled = true;
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Tom Flattery";
    userEmail = "tomjflattery@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
