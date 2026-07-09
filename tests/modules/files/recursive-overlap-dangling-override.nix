{ pkgs, ... }:

{
  home.fileOverlapResolution = "override";
  home.file = {
    "foo" = {
      source = pkgs.runCommand "foo-recursive-dangling" { } ''
        mkdir $out
        echo -n foo > $out/foo
        ln -s /nonexistent/nowhere $out/bar
      '';
      recursive = true;
    };
    "foo/bar".text = "bar override";
  };

  nmt.script = ''
    assertFileExists 'home-files/foo/foo';
    assertFileContent 'home-files/foo/foo' \
      ${builtins.toFile "foo-expected" "foo"}

    # A dangling symlink from the recursively linked directory is still a
    # conflict. Under "override" the dangling entry must be removed and
    # replaced by the regularly linked file rather than crashing the build.
    assertFileExists 'home-files/foo/bar';
    assertFileContent 'home-files/foo/bar' \
      ${builtins.toFile "bar-expected" "bar override"}
  '';
}
