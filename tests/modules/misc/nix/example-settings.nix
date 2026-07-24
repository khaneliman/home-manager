{
  config,
  lib,
  pkgs,
  ...
}:

{
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

    nixPath = [
      "/a"
      "/b/c"
    ];

    settings = {
      sandbox = true;
      show-trace = true;
      system-features = [
        "big-parallel"
        "kvm"
        "recursive-nix"
      ];
    };
  };

  nmt.script = ''
    assertFileContent \
      home-files/.config/nix/nix.conf \
      ${./example-settings-expected.conf}

    assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
      '__hm_new="/a:/b/c"'
    assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
      '__hm_cur="''${NIX_PATH-}"'
  '';
}
