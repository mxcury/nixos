{ config, pkgs, ... }:

{
  # Additional Wayland tools
  home.packages = with pkgs; [
    waybar
    mako
    rofi
    swaylock-effects
    swww
    wlogout
    wdisplays
    pavucontrol
    blueman
    brightnessctl
    networkmanagerapplet
  ];

  # Waybar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        
        modules-left = [
          "custom/power"
          "clock"
          "network"
          "bluetooth"
          "pulseaudio#microphone"
        ];
        
        modules-center = [
          "hyprland/workspaces"
          "custom/power-profile"
        ];
        
        modules-right = [
          "battery#bar"
          "pulseaudio#bar"
          "backlight#bar"
        ];

        "custom/power" = {
          format = "[⏻]";
          on-click = "wlogout";
          tooltip = false;
        };

        clock = {
          format = "[ {:%H:%M} ]";
          format-alt = "[ {:%Y-%m-%d} ]";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        network = {
          format = "[ {icon} ]";
          format-wifi = "󰖩";
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "nm-applet";
        };

        bluetooth = {
          format = "[ {icon} ]";
	  format-on = "󰂯";
          format-connected = "󰂯";
          format-disabled = "󰂲";
          format-off = "󰂲";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        "pulseaudio#microphone" = {
          format = "[ {format_source} ]";
          format-source = "󰍬";
          format-source-muted = "󰍭";
          on-click = "pavucontrol -t 4";
          tooltip = true;
        };

        "hyprland/workspaces" = {
          format = "{id}";
          on-click = "activate";
          sort-by-number = true;
          all-outputs = false;
        };

        "custom/power-profile" = {
          exec = "~/.config/waybar/scripts/power-profile.sh";
          return-type = "json";
          interval = 5;
          on-click = "~/.config/waybar/scripts/power-profile-toggle.sh";
          format = "{}";
        };

        "battery#bar" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "[{capacity}% {icon}]";
          format-charging = "{capacity}% 󱐋 {icon}]";
          format-plugged = "{capacity}%  {icon}";
          format-icons = ["░░░░░░░░░░" "█░░░░░░░░░" "██░░░░░░░░" "███░░░░░░░" "████░░░░░░" "█████░░░░░" "██████░░░░" "███████░░░" "████████░░" "█████████░" "██████████"];
          tooltip-format = "{timeTo}, {capacity}%";
        };

        "pulseaudio#bar" = {
          format = "[{volume}% {icon}]";
          format-muted = "[  ░░░░░░░░░░]";
          format-icons = {
            default = ["░░░░░░░░░░" "█░░░░░░░░░" "██░░░░░░░░" "███░░░░░░░" "████░░░░░░" "█████░░░░░" "██████░░░░" "███████░░░" "████████░░" "█████████░" "██████████"];
          };
          on-click = "pavucontrol";
        };

        "backlight#bar" = {
          format = "{percent}%  {icon}";
          format-icons = ["░░░░░░░░░░" "█░░░░░░░░░" "██░░░░░░░░" "███░░░░░░░" "████░░░░░░" "█████░░░░░" "██████░░░░" "███████░░░" "████████░░" "█████████░" "██████████"];
          on-scroll-up = "brightnessctl set 5%+";
          on-scroll-down = "brightnessctl set 5%-";
        };
      };
    };
    
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
        min-height: 0;
      }

      window#waybar {
        background: #1e1e2e;
        color: #cdd6f4;
      }

      /* Remove individual backgrounds - all modules transparent */
      #custom-power,
      #clock,
      #network,
      #bluetooth,
      #pulseaudio.microphone,
      #custom-power-profile,
      #battery.bar,
      #pulseaudio.bar,
      #backlight.bar {
        padding: 0 10px;
        margin: 0 4px;
        background: transparent;
      }

      /* Left modules */
      #custom-power {
        color: #f38ba8;
        font-weight: bold;
      }

      #custom-power:hover {
        background: rgba(243, 139, 168, 0.2);
      }

      #clock {
        color: #89b4fa;
      }

      #network {
        color: #a6e3a1;
      }

      #bluetooth {
        color: #89dceb;
      }

      #pulseaudio.microphone {
        color: #f9e2af;
      }

      /* Center modules */
      #workspaces {
        margin: 0;
        padding: 0;
        background: transparent;
      }

      #workspaces button {
        padding: 0 8px;
        margin: 0 2px;
        background: transparent;
        color: #6c7086;
        transition: all 0.3s ease;
      }

      #workspaces button.active {
        color: #89b4fa;
        font-weight: bold;
      }

      #workspaces button:hover {
        color: #cdd6f4;
      }

      #custom-power-profile {
        color: #cba6f7;
        min-width: 120px;
      }

      /* Right modules - bar graphs */
      #battery.bar,
      #pulseaudio.bar,
      #backlight.bar {
        font-family: monospace;
        min-width: 150px;
      }

      #battery.bar {
        color: #a6e3a1;
      }

      #battery.bar.warning {
        color: #f9e2af;
      }

      #battery.bar.critical {
        color: #f38ba8;
        animation: blink 1s linear infinite;
      }

      #battery.bar.charging {
        color: #89dceb;
      }

      #pulseaudio.bar {
        color: #89b4fa;
      }

      #backlight.bar {
        color: #f9e2af;
      }

      @keyframes blink {
        0% {
          opacity: 1;
        }
        50% {
          opacity: 0.5;
        }
        100% {
          opacity: 1;
        }
      }

      /* Tooltips */
      tooltip {
        background: rgba(30, 30, 46, 0.95);
        border: 1px solid rgba(137, 180, 250, 0.5);
        border-radius: 8px;
      }

      tooltip label {
        color: #cdd6f4;
      }
    '';
  };

  # Create waybar scripts directory and files
  home.file.".config/waybar/scripts/power-profile.sh" = {
    text = ''
      #!/usr/bin/env bash
      profile=$(powerprofilesctl get)

      case $profile in
        "power-saver")
          text="Energy Saving"
          ;;
        "balanced")
          text="Normal"
          ;;
        "performance")
          text="Overdrive"
          ;;
        *)
          text="Unknown"
          ;;
      esac

      echo "{\"text\":\"$text\",\"tooltip\":\"Power Profile: $text\",\"class\":\"$profile\"}"
    '';
    executable = true;
  };

  home.file.".config/waybar/scripts/power-profile-toggle.sh" = {
    text = ''
      #!/usr/bin/env bash
      current=$(powerprofilesctl get)

      case $current in
        "power-saver")
          powerprofilesctl set balanced
          ;;
        "balanced")
          powerprofilesctl set performance
          ;;
        "performance")
          powerprofilesctl set power-saver
          ;;
      esac
    '';
    executable = true;
  };

  # Mako notification daemon
  services.mako = {
    enable = true;
    extraConfig = ''
      text-color=#ECEFF4
      border-color=#88C0D0
      default-timeout=5000
    '';
  };

  # Rofi launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "Arc-Dark";
    terminal = "${pkgs.kitty}/bin/kitty";
  };

  # Swaylock
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      color = "000000";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };  
}
