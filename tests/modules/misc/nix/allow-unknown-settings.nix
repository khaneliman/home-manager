{ config, lib, pkgs, ... }: {
  nix = {
    package = config.lib.test.mkStubPackage {
      version = lib.getVersion pkgs.nixVersions.stable;
      buildScript = ''
        target=$out/bin/nix
        mkdir -p "$(dirname "$target")"

        echo -n "true" > "$target"

        chmod +x "$target"
      '';
    };

    allowUnknownSettings = true;

    settings = {
      some-arbitrary-setting = true;
      and-another-one = "hello";
    };
  };

  nmt.script = ''
    assertFileContent \
      home-files/.config/nix/nix.conf \
      ${./allow-unknown-settings-expected.conf}
  '';
}
