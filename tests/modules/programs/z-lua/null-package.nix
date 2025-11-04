{
  config = {
    programs.z-lua = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, z-lua should not be added to home.packages
      assertPathNotExists home-path/bin/z.lua
    '';
  };
}
