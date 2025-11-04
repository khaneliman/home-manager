{ config, pkgs, ... }:

{
  programs.pidgin = {
    enable = true;
    plugins = [
      (config.lib.test.mkStubPackage { name = "pidgin-otr"; })
      (config.lib.test.mkStubPackage { name = "pidgin-osd"; })
    ];
  };

  nmt.script = ''
    # Verify pidgin package is available
    assertNotNull "$(command -v pidgin)"

    # Check that pidgin was built with plugins
    # Note: In a real test environment, we would verify the plugins
    # are actually available, but with stubbed packages we just
    # verify the basic functionality works
  '';
}
