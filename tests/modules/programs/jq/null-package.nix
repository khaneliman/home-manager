{
  config = {
    programs.jq = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, jq should not be added to home.packages
      assertFileNotRegex home-path/etc/profiles/per-user/${config.home.username}/bin/jq ''
    '';
  };
}