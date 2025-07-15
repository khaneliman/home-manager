{ config, ... }:

{
  config = {
    programs.keychain.enable = true;

    nmt.script = ''
      # Test bash integration (enabled by default)
      assertFileExists home-files/.bashrc
      assertFileRegex home-files/.bashrc 'keychain.*--eval.*--quiet.*id_rsa'

      # Test xsession integration (enabled by default) 
      assertFileExists home-files/.xsession
      assertFileRegex home-files/.xsession 'keychain.*--eval.*--quiet.*id_rsa'
    '';
  };
}
