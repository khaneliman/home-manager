{ config, ... }:

{
  config = {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [
        "--no-cmd"
        "--hook"
        "pwd"
      ];
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.bashrc \
        'eval.*zoxide.*init bash --no-cmd --hook pwd'
    '';
  };
}
