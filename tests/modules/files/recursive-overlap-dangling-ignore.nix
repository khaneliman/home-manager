{ pkgs, ... }:

{
  home.fileOverlapResolution = "ignore";
  home.file = {
    "foo" = {
      source = pkgs.runCommand "foo-recursive-dangling" { } ''
        mkdir $out
        echo -n foo > $out/foo
        ln -s /nonexistent/nowhere $out/bar
      '';
      recursive = true;
    };
    "foo/bar".text = "bar ignore";
  };

  nmt.script = ''
    assertFileExists 'home-files/foo/foo';
    assertFileContent 'home-files/foo/foo' \
      ${builtins.toFile "foo-expected" "foo"}

    # A dangling symlink from the recursively linked directory is still a
    # conflict. Under "ignore" that means the build must not crash and the
    # original (dangling) entry must be kept rather than replaced.
    assertLinkExists 'home-files/foo/bar'

    if [[ -e "$TESTED/home-files/foo/bar" ]]; then
      fail "Expected home-files/foo/bar to remain a dangling symlink under ignore resolution, but it resolves to a real file."
    fi
  '';
}
