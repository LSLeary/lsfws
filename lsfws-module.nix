{ pkgs, lib, config, ... }: with lib;
let
  inherit (lib) mkOption mkIf literalExample;
  cfg = config.programs.lsfws;
  lsfws = pkgs.callPackage ./lsfws.nix { inherit (cfg) browser; };
in
{ options.programs.lsfws = {
    enable = mkEnableOption "lsfws";
    browser = {
      drv = mkOption {
        default = pkgs.chromium;
        defaultText = "pkgs.chromium";
        type = types.package;
        example = literalExample "pkgs.firefox";
        description =
          "The browser used to access the local static file web server.";
      };
      binName = mkOption {
        default = "chromium";
        defaultText = ''"chromium"'';
        type = types.str;
        example = literalExample ''"firefox"'';
        description = "The file name of the binary to use in the provided drv.";
      };
    };
    serveNixStore = mkOption {
      default = true;
      defaultText = "true";
      type = types.bool;
      example = literalExample "false";
      description = "Whether or not to serve the nix store.";
    };
    serveUser = {
      enable = mkOption {
        default = false;
        defaultText = "false";
        type = types.bool;
        example = literalExample "true";
        description = ''
          Whether to serve a user's home directory. Note enabling this option
          causes httpd to run as that user.
        '';
      };
      username = mkOption {
        default = null;
        defaultText = "null";
        type = types.nullOr types.str;
        example = "leary";
        description = ''
          The user whose home directory will be served. httpd will run as this
          user.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ lsfws ];
    services.httpd = {
      enable = true;
      servedDirs =
        optionals cfg.serveNixStore
          [ rec { dir = "/nix/store"; urlPath = dir; } ] ++
        optionals cfg.serveUser.enable
          [ rec { dir = "/home/${cfg.serveUser.username}"; urlPath = dir; } ];
      user = mkIf cfg.serveUser.enable cfg.serveUser.username;
      adminAddr = "admin@email.com"; # Apparently we need this?
    };
  };
}
