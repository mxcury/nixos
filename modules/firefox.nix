systemd.user.services.firefox-daemon = {
  description = "Firefox background daemon for instant window opening";
  after = [ "graphical-session.target" ];
  partOf = [ "graphical-session.target" ];
  wantedBy = [ "graphical-session.target" ];
  
  serviceConfig = {
    Type = "simple";
    ExecStart = "${pkgs.writeShellScript "firefox-daemon" ''
      export DISPLAY=:0
      export WAYLAND_DISPLAY=wayland-1
      
      while true; do
        # Launch Firefox
        ${pkgs.firefox}/bin/firefox &
        FIREFOX_PID=$!
        
        # Wait for Firefox window to appear
        while ! ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.class=="firefox")' > /dev/null 2>&1; do
          sleep 0.1
          # Check if Firefox crashed during startup
          if ! kill -0 $FIREFOX_PID 2>/dev/null; then
            break
          fi
        done
        
        # Close the window if it appeared
        if ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -e '.[] | select(.class=="firefox")' > /dev/null 2>&1; then
          ${pkgs.hyprland}/bin/hyprctl dispatch closewindow firefox
        fi
        
        # Wait for Firefox process to exit
        wait $FIREFOX_PID
        
        # Firefox exited, wait a bit before restarting
        sleep 1
      done
    ''}";
    Restart = "always";
    RestartSec = "3";
  };
};
