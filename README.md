# lsfws
This repository provides a simple wrapper around the browser of your choice that
will open local files through a local static file web server which the nixos
module sets up by enabling certain `services.httpd` options. The wrapper has a
.desktop file, so it can be used with xdg-open.

## Usage
Clone this repository, then add the provided module to your configuration.nix
imports and configure lsfws through the provided `programs.lsfws` options. E.g.

```nix
{ config, pkgs, ... }:

{ imports = [ /path/to/lsfws-module.nix ];

  programs.lsfws = {
    enable = true;
    # You can serve a user's home directory.
    serveUser = {
      enable = true;
      username = "leary";
    };
    # All further options reproduce the defaults.
    serveNixStore = true;
    browser = {
      # derivation used for the browser.
      drv = pkgs.chromium;
      # which executable to use from the browser derivation's bin directory.
      binName = "chromium";
    };
  };
}
```

## XDG
Unfortunately NixOS doesn't have declaritive xdg mime association configuration
yet, so to set lsfws as a default, run e.g.

```sh
xdg-mime default lsfws.desktop text/html
```

Nix doesn't link shares by default, so this may require adding
`/share/applications` to the `environment.pathsToLink` option.

## open-haddock
lsfws was originally written for use with the excellent jml/open-haddock
utility; check it out if you write haskell and use nix.

## Feedback
Have tips for improving any part of this repository? Let me know on irc or submit
an issue.
