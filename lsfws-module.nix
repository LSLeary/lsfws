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
        type = with types; package;
        example = literalExample "pkgs.firefox";
        description =
          "The browser used to access the local static file web server.";
      };
      binName = mkOption {
        default = "chromium";
        defaultText = ''"chromium"'';
        type = with types; str;
        example = literalExample ''"firefox"'';
        description = "The file name of the binary to use in the provided drv.";
      };
    };
    serveNixStore = mkOption {
      default = true;
      defaultText = "true";
      type = with types; bool;
      example = literalExample "false";
      description = "Whether or not to serve the nix store.";
    };
    serveUser = {
      enable = mkOption {
        default = false;
        defaultText = "false";
        type = with types; bool;
        example = literalExample "true";
        description = ''
          Whether to serve a user's home directory. Note enabling this option
          causes httpd to run as that user.
        '';
      };
      username = mkOption {
        default = null;
        defaultText = "null";
        type = with types; nullOr str;
        example = "leary";
        description = ''
          The user whose home directory will be served. httpd will run as this
          user.
        '';
      };
    };
    otherServes = mkOption {
      default = [];
      defaultText = "[]";
      type = with types; listOf path;
      example = literalExample ''[ /media/ExtHDD ]'';
      description = "Other directories to serve.";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ lsfws ];
    services.httpd = {
      enable = true;
      user = mkIf cfg.serveUser.enable cfg.serveUser.username;
      virtualHosts.lsfws.servedDirs =
        map (dir: { inherit dir; urlPath = dir; }) (
          map builtins.toString cfg.otherServes ++
          optionals cfg.serveNixStore [ "/nix/store" ] ++
          optionals cfg.serveUser.enable [ "/home/${cfg.serveUser.username}" ]
        );
    };
  };
}
