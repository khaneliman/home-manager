{
  config = {
    programs.just.enable = true;

    test.asserts.warnings.expected = [
      "'program.just' is deprecated, simply add 'pkgs.just' to 'home.packages' instead.\nSee https://github.com/nix-community/home-manager/issues/3449#issuecomment-1329823502"
    ];

    nmt.script = ''
      # The deprecated module should not create any files
      assertPathNotExists home-files/.config/just
    '';
  };
}
