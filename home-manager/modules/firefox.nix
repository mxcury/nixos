{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    
    profiles.default = {
      settings = {
        # Disable slow startup features
        "browser.startup.preXulSkeletonUI" = false;
        "browser.startup.homepage" = "about:blank";
        
        # Hardware acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        
        # Reduce disk I/O
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.enable" = true;
        "browser.cache.memory.capacity" = 512000;
        
        # Disable unnecessary features at startup
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
      };
    };
  };
}
