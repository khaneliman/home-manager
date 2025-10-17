{
  lib,
  options,
  ...
}:

{
  programs.git = {
    enable = true;
    lfs = {
      enable = true;
      skipSmudge = true;
    };
  };

  test.asserts.warnings.expected = [
    "The option `programs.git.lfs.skipSmudge' defined in ${lib.showFiles options.programs.git.lfs.skipSmudge.files} has been renamed to `programs.git-lfs.skipSmudge'."
    "The option `programs.git.lfs.enable' defined in ${lib.showFiles options.programs.git.lfs.enable.files} has been changed to `programs.git-lfs.enable' that has a different type. Please read `programs.git-lfs.enable' documentation and update your configuration accordingly."
    "`programs.git-lfs.enableGitIntegration` automatic enablement is deprecated. Please explicitly set `programs.git-lfs.enableGitIntegration = true`."
  ];

  nmt.script = ''
    # Git config should contain git-lfs configuration (backward compatibility)
    assertFileExists home-files/.config/git/config
    assertFileContains home-files/.config/git/config '[filter "lfs"]'
    assertFileContains home-files/.config/git/config 'clean = "git-lfs clean -- %f"'
    assertFileRegex home-files/.config/git/config 'process = "git-lfs filter-process --skip"'
    assertFileContains home-files/.config/git/config 'required = true'
    assertFileRegex home-files/.config/git/config 'smudge = "git-lfs smudge --skip -- %f"'
  '';
}
