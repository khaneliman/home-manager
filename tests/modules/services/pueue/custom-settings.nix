{ ... }:

{
  services.pueue = {
    enable = true;
    settings = {
      daemon = {
        default_parallel_tasks = 2;
        host = "127.0.0.1";
        port = 6924;
      };
      client = {
        restart_in_place = false;
      };
    };
  };

  test.stubs.pueue = { };

  nmt.script = ''
    assertFileExists home-files/.config/pueue/pueue.yml
    assertFileContent \
      home-files/.config/pueue/pueue.yml \
      ${./custom-settings-expected.yml}
  '';
}
