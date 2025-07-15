{ config, ... }:
{
  dunstStubPackage = config.lib.test.mkStubPackage {
    name = "dunst";
    buildScript = ''
      mkdir -p $out/{bin,share/dbus-1/services}

      # Create the binary
      echo '#!/bin/sh' > $out/bin/dunst
      echo 'echo "dunst stub $@"' >> $out/bin/dunst
      chmod +x $out/bin/dunst

      # Create the dbus service file
      cat > $out/share/dbus-1/services/org.knopwob.dunst.service << 'EOF'
        [D-BUS Service]
        Name=org.knopwob.dunst
        Exec=@dunst@/bin/dunst
        EOF
    '';
  };
}
