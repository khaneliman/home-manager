{
  config,
  ...
}:

{
  config = {
    services.dunst = {
      enable = true;
    };

    test.stubs.dunst = { };

    nmt.script = ''
      assertFileExists home-files/.local/share/dbus-1/services/org.knopwob.dunst.service

      # Check that the D-Bus service file is linked correctly from the package
      serviceFile=$(readlink home-files/.local/share/dbus-1/services/org.knopwob.dunst.service)
      if [[ "$serviceFile" != "@dunst@/share/dbus-1/services/org.knopwob.dunst.service" ]]; then
        echo "Expected D-Bus service file link to point to package, but got: $serviceFile"
        exit 1
      fi
    '';
  };
}
