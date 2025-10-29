{ config, pkgs, ... }:

{
  imports = [
    ./scripts/power-profiles/power-profiles.nix
    ./styling/waybar.nix
  ];

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
          "hyprland/workspaces#left"
          "custom/power-profile"
          "hyprland/workspaces#right"
        ];

        modules-right = [
          "battery#bar"
          "pulseaudio#bar"
          "backlight#bar"
        ];

        "custom/power" = {
          format = "[ ⏻ ]";
          on-click = "wlogout";
          tooltip = false;
        };

        clock = {
          format = "[ {:%H:%M} ]";
          format-alt = "[ {:%Y-%m-%d} ]";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        network = {
          format = "{icon}";
          format-icons = {
            wifi = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            ethernet = "󰈀";
            disconnected = "󰤫";
            disabled = "󰤮";
          };
          format-wifi = "[ {icon} ]";
          format-ethernet = "[ {icon} ]";
          format-disconnected = "[ {icon} ]";
          format-disabled = "[ {icon} ]";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}";
          tooltip-format-disconnected = "Disconnected";
          tooltip-format-disabled = "Disabled";
          on-click = "nm-applet";
        };

        bluetooth = {
          format = "[ 󰂯 ]";
          format-on = "[ 󰂯 ]";
          format-connected = "[ 󰂱 ]";
          format-off = "[ 󰂲 ]";
          format-disabled = "[ 󰂲 ]";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-disabled = "Disabled";
          on-click = "blueman-manager";
        };

        "pulseaudio#microphone" = {
          format = "[ {format_source} ]";
          format-source = "󰍬";
          format-source-muted = "󰍭";
          on-click = "pavucontrol -t 4";
          tooltip = true;
        };

        "hyprland/workspaces#left" = {
          on-click = "activate";
          sort-by-number = true;
          format = "[{id}]";
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
          };
          ignore-workspaces = ["[^123]"];
        };

        "hyprland/workspaces#right" = {
          on-click = "activate";
          sort-by-number = true;
          format = "[{id}]";
          persistent-workspaces = {
            "4" = [];
            "5" = [];
            "6" = [];
          };
          ignore-workspaces = ["[123]"];
        };

        "custom/power-profile" = {
          exec = "~/.config/waybar/scripts/power-profile.sh";
          return-type = "json";
          interval = 2;
          on-click = "~/.config/waybar/scripts/power-profile-toggle.sh";
          format = "[ {} ]";
        };

        "battery#bar" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% [ {icon} ]";
          format-charging = "{capacity}% 󱐋 [ {icon} ]";
          format-plugged = "{capacity}%  [ {icon} ]";
          format-icons = ["░░░░░░░░░░" "█░░░░░░░░░" "██░░░░░░░░" "███░░░░░░░" "████░░░░░░" "█████░░░░░" "██████░░░░" "███████░░░" "████████░░" "█████████░" "██████████"];
          tooltip-format = "{timeTo}, {capacity}%";
        };

        "pulseaudio#bar" = {
          format = "{volume}% [ {icon} ]";
          format-muted = "  [ ░░░░░░░░░░ ]";
          format-icons = {
            default = ["░░░░░░░░░░" "█░░░░░░░░░" "██░░░░░░░░" "███░░░░░░░" "████░░░░░░" "█████░░░░░" "██████░░░░" "███████░░░" "████████░░" "█████████░" "██████████"];
          };
          on-click = "pavucontrol";
        };

        "backlight#bar" = {
          format = "{percent}%  [ {icon} ]";
          format-icons = ["░░░░░░░░░░" "█░░░░░░░░░" "██░░░░░░░░" "███░░░░░░░" "████░░░░░░" "█████░░░░░" "██████░░░░" "███████░░░" "████████░░" "█████████░" "██████████"];
          on-scroll-up = "brightnessctl set 5%+";
          on-scroll-down = "brightnessctl set 5%-";
        };
      };
    };
  };
}
