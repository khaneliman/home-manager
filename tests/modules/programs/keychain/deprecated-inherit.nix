{ config, ... }:

{
  config = {
    programs.keychain = {
      enable = true;
      package = config.lib.test.mkStubPackage {
        name = "keychain";
        version = "2.9.0";
        outPath = "@keychain@";
      };
      inheritType = "local";
    };

    test.asserts.warnings.expected = [
      ''
        Option `programs.keychain.inheritType` is deprecated and will be removed in the future.
        Please avoid using it.
        See https://github.com/funtoo/keychain/releases/tag/2.9.0 for more information
      ''
    ];

    nmt.script = ''
      # Test that inheritType option generates warning but still works
      assertFileExists home-files/.bashrc
      assertFileRegex home-files/.bashrc 'keychain.*--inherit.*local'
    '';
  };
}
