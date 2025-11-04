{ config, ... }:

{
  config = {
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--max-columns-preview"
        "--colors=line:style:bold"
        "--colors=path:fg:green"
        "--smart-case"
        "--follow"
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/ripgrep/ripgreprc
      assertFileContent \
        home-files/.config/ripgrep/ripgreprc \
        ${./with-arguments-expected.conf}

      assertFileRegex home-path/etc/profile.d/hm-session-vars.sh \
        'export RIPGREP_CONFIG_PATH=.*ripgreprc'
    '';
  };
}
