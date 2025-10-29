{ config, pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    
    settings = {
      # Monitor configuration
      monitor = ",preferred,auto,1";

      # Execute at launch
      exec-once = [
        "waybar"
        "mako"
        "nm-applet --indicator"
        "blueman-applet"
        "swww-daemon"
	"[workspace special:hidden silent] firefox"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];
      
      # Input configuration
      input = {
        kb_layout = "gb";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 0;
      };
      
      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89dcebee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        # Performance: reduce visual overhead
        no_border_on_floating = false;
      };
      
      # Decoration - Optimized for performance
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          # Performance improvements
          new_optimizations = true;
          xray = false;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          color = "rgba(00000099)";
          # Reduce shadow rendering overhead
          range = 4;
          render_power = 3;
        };
        # Disable dim for better performance
        dim_inactive = false;
      };

      # Animations - Faster and snappier
      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
          "snappy, 0.1, 0.9, 0.1, 1.0"
        ];
        animation = [
          # Reduced animation times for snappier feel
          "windows, 1, 4, snappy, popin 95%"
          "windowsOut, 1, 4, default, popin 95%"
          "border, 1, 5, default"
          "borderangle, 1, 5, default"
          "fade, 1, 4, default"
          "workspaces, 1, 3, default, slide"
        ];
      };
      
      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        # Disable smart splits for faster tiling
        smart_split = false;
      };
      
      # Misc performance settings
      misc = {
        # Disable the anime mascot wallpaper
        force_default_wallpaper = 0;
        # Reduce unnecessary redraws
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        # Performance
        vfr = true;  # Variable refresh rate
        vrr = 0;     # Adaptive sync (set to 1 if you have VRR display)
        # Faster focus switching
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
      };
      
      # Render settings for performance
      render = {
        # Enable direct scanout for better performance
        direct_scanout = true;
      };
      
      gestures = {
        gesture = "3, horizontal, workspace";
      };

      # Key bindings
      "$mod" = "SUPER";
      
      bind = [
        # Window management
        "$mod, Q, killactive"
        "$mod, ESCAPE, exit"
        "$mod SHIFT, V, togglefloating"
        "$mod SHIFT, P, pseudo"
        "$mod SHIFT, J, togglesplit"
        "$mod SHIFT, F, fullscreen"
	"$mod SHIFT, S, togglespecialworkspace"
        
        # Applications
        "$mod, RETURN, exec, kitty"
        "$mod, SPACE, exec, rofi -show drun"
        "$mod, F, exec, kitty -e superfile"
        "$mod, E, exec, firefox"
        
        # Focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        
        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        
        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Workspace switching
        "$mod SHIFT, right, exec, ${pkgs.writeShellScript "workspace-cycle-next" ''
          current=$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq '.id')
          next=$((current + 1))
          [ $next -gt 6 ] && next=1
          ${pkgs.hyprland}/bin/hyprctl dispatch workspace $next
        ''}"
      
        "$mod SHIFT, left, exec, ${pkgs.writeShellScript "workspace-cycle-prev" ''
          current=$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq '.id')
          next=$((current - 1))
          [ $next -lt 1 ] && next=6
          ${pkgs.hyprland}/bin/hyprctl dispatch workspace $next
        ''}"

	# Move window to next/previous workspace (with looping)
        "$mod SHIFT CTRL, right, exec, ${pkgs.writeShellScript "movewindow-cycle-next" ''
          current=$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq '.id')
          next=$((current + 1))
          [ $next -gt 6 ] && next=1
          ${pkgs.hyprland}/bin/hyprctl dispatch movetoworkspace $next
        ''}"

        "$mod SHIFT CTRL, left, exec, ${pkgs.writeShellScript "movewindow-cycle-prev" ''
          current=$(${pkgs.hyprland}/bin/hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq '.id')
          next=$((current - 1))
          [ $next -lt 1 ] && next=6
          ${pkgs.hyprland}/bin/hyprctl dispatch movetoworkspace $next
        ''}"
        
        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        
        # Lock screen
        "$mod, L, exec, swaylock"

        # Function Keys (ThinkPad T480s)
        # F1: Audio mute
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        
        # F4: Microphone mute
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        
        # F7: Display toggle
        ", XF86Display, exec, wdisplays"
        
        # F8: WiFi toggle
        ", XF86WLAN, exec, nmcli radio wifi toggle"
        ", F8, exec, nmcli radio wifi toggle"
        
        # F9: Settings (open system settings)
        ", XF86Tools, exec, kitty -e nmtui"
        
        # F10: Bluetooth toggle
        ", XF86Bluetooth, exec, bluetoothctl power toggle"
        ", F10, exec, bluetoothctl power toggle"
        
        # F11: Keyboard settings (open keyboard layout switcher or settings)
        ", XF86Keyboard, exec, rofi -show drun -filter keyboard"
        
        # F12: Favorites (open file manager or bookmarks)
        ", XF86Favorites, exec, kitty -e superfile"
      ];

      # Volume and brightness controls (repeatable bindings)
      binde = [
        # F2: Volume down
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        
        # F3: Volume up
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        
        # F5: Brightness down
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        
        # F6: Brightness up
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
      ];
      
      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Window rules for faster startup
      windowrulev2 = [
        # Immediate rendering for common apps
        "immediate, class:^(kitty)$"
        "immediate, class:^(firefox)$"
      ];
    };
  };
  
  # Cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
}
