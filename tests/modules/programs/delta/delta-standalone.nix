{ config, ... }:

{
  programs.delta = {
    enable = true;
    package = config.lib.test.mkStubPackage {
      name = "delta";
      buildScript = ''
        mkdir -p $out/bin
        touch $out/bin/delta
        chmod 755 $out/bin/delta
      '';
    };
    options = {
      features = "line-numbers decorations";
      syntax-theme = "Dracula";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
      };
    };
  };

  # Git is NOT enabled, testing standalone delta usage
  programs.git.enable = false;

  nmt.script = ''
    # Delta package should be installed
    assertFileExists home-path/bin/delta

    # Git config should NOT exist or contain delta configuration
    if [[ -f home-files/.config/git/config ]]; then
      assertFileNotRegex home-files/.config/git/config 'pager = .*/bin/delta'
      assertFileNotRegex home-files/.config/git/config '\[delta\]'
    fi

    # Verify the wrapper passes the config flag
    # The wrapper script should contain --config flag
    assertFileRegex home-path/bin/delta '\-\-config'
  '';
}
