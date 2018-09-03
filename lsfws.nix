{ bash, stdenv, coreutils, gnused, makeDesktopItem, browser }:

let desktopFile = makeDesktopItem rec {
  name = "lsfws";
  exec = name;
  mimeType = "text/html";
  comment = ''
    Opens html files through the local static file web server rather than the
    file:// protocol.
  '';
  desktopName = name;
  genericName = name;
  categories = "Utility";
};

in stdenv.mkDerivation {
  name    = "lsfws";
  src     = ./src;
  builder = "${bash}/bin/bash";
  args    = [ ./builder.sh ];
  system  = builtins.currentSystem;
  inherit desktopFile;
  browser = with browser; "${drv}/bin/${binName}";
  PATH    = "${coreutils}/bin:${gnused}/bin";
}

