{ config, pkgs, ... }:

{
  programs.waybar.style = ''
    * {
      border: none;
      border-radius: 0;
      font-family: "JetBrainsMono Nerd Font Propo";
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
}
