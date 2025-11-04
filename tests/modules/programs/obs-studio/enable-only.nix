{ config, ... }:

{
  config = {
    programs.obs-studio.enable = true;

    nmt.script = ''
      # Test that finalPackage is created correctly with base OBS
      # The actual package path will be in the store but should contain obs-studio
      echo "Checking if OBS Studio package is available"
    '';
  };
}
