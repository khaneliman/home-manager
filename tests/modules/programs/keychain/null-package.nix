{
  config = {
    programs.keychain = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, keychain should not be added to home.packages
      assertPathNotExists home-path/bin/keychain
    '';
  };
}
