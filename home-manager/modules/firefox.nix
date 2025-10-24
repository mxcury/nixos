{ config, pkgs, lib, ... }:

let
  firefox-with-libs = pkgs.writeShellScriptBin "firefox" ''
    # Add necessary libraries to LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [
      # Graphics/GPU
      pkgs.mesa
      pkgs.libglvnd
      pkgs.libva
      pkgs.libdrm
      
      # System
      pkgs.pciutils
      pkgs.dbus
      pkgs.systemd
      
      # Wayland/X11
      pkgs.wayland
      pkgs.xorg.libX11
      pkgs.xorg.libxcb
      pkgs.xorg.libXext
      
      # GTK/UI
      pkgs.gtk3
      pkgs.glib
      pkgs.pango
      pkgs.cairo
      pkgs.gdk-pixbuf
      
      # Audio (if needed)
      pkgs.libpulseaudio
      pkgs.alsa-lib
    ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    
    # Wayland support
    export MOZ_ENABLE_WAYLAND=1
    export MOZ_DBUS_REMOTE=1
    
    # GTK settings
    export GTK_PATH="${pkgs.gtk3}/lib/gtk-3.0"
    export GDK_PIXBUF_MODULE_FILE="${pkgs.librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    
    # Run Firefox
    exec ${pkgs.firefox-unwrapped}/bin/firefox "$@"
  '';
in
{
  home.packages = [ firefox-with-libs ];
}
