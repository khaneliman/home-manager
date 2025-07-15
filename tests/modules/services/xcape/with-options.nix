{ config, ... }:

{
  config = {
    services.xcape = {
      enable = true;
      timeout = 500;
      mapExpression = {
        Shift_L = "Escape";
        Control_L = "Control_L|O";
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/xcape.service \
        ${./with-options-expected.service}
    '';
  };
}
