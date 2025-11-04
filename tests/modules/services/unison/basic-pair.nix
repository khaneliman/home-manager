{ config, ... }:

{
  config = {
    services.unison = {
      enable = true;
      pairs = {
        "my-documents" = {
          roots = [
            "/home/user/documents"
            "ssh://remote/documents"
          ];
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/unison-pair-my-documents.service
      assertFileContent \
        home-files/.config/systemd/user/unison-pair-my-documents.service \
        ${./basic-pair-expected.service}

      assertFileExists home-files/.config/systemd/user/unison-pair-my-documents.timer
      assertFileContent \
        home-files/.config/systemd/user/unison-pair-my-documents.timer \
        ${./basic-pair-expected.timer}
    '';
  };
}
