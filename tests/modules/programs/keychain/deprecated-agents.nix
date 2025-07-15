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
      agents = [
        "ssh"
        "gpg"
      ];
    };

    test.asserts.warnings.expected = [
      ''
        Option `programs.keychain.agents` is deprecated and will be removed in the future.
        Please avoid using it.
        See https://github.com/funtoo/keychain/releases/tag/2.9.0 for more information
      ''
    ];
  };
}
