mkdir -p $out/bin $out/share/applications &&
sed -e "s:browser:$browser:g" $src/lsfws > $out/bin/lsfws &&
chmod 755 $out/bin/lsfws &&
ln -s $desktopFile/share/applications/lsfws.desktop $out/share/applications
