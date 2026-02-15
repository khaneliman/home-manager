{ pkgs, ... }:

{
  qt = {
    enable = true;
    kvantum = {
      theme.name = "KvAdapta";
      applications = {
        THEME1 = [
          "app1"
          "app2"
        ];
        THEME2 = [ "app3" ];
      };
    };
  };

  nmt.script =
    let
      configPath = "home-files/.config/Kvantum/kvantum.kvconfig";

      expectedContent = pkgs.writeText "expected.kvconfig" ''
        [Applications]
        THEME1=app1, app2
        THEME2=app3

        [General]
        theme=KvAdapta
      '';
    in
    ''
      assertFileExists "${configPath}"
      assertFileContent "${configPath}" "${expectedContent}"
    '';
}
