{ config, ... }:

{
  config = {
    services.mbsync = {
      enable = true;
      preExec = "mkdir -p %h/mail";
      postExec = "mu index";
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/mbsync.service \
        ${./with-hooks-expected.service}
    '';
  };
}
