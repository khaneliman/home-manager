{
  config = {
    programs.opam = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, opam should not be added to home.packages
      assertPathNotExists home-path/bin/opam
    '';
  };
}
