{ config, pkgs, ... }:

let
  exampleChannel = pkgs.writeTextDir "default.nix" ''
    { pkgs ? import <nixpkgs> { } }:

    {
      example = pkgs.emptyDirectory;
    }
  '';
in
{
  nix = {
    package = config.lib.test.mkStubPackage { };
    channels.example = exampleChannel;
  };

  nmt.script = ''
    assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
      '__hm_new="/home/hm-user/.nix-defexpr/50-home-manager"'
    assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
      '__hm_cur="''${NIX_PATH-}"'
    assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
      '  export NIX_PATH="$__hm_add''${__hm_cur:+:}$__hm_cur"'
    assertFileContent \
      home-files/.nix-defexpr/50-home-manager/example/default.nix \
      ${exampleChannel}/default.nix
  '';
}
