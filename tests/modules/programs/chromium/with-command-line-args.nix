{ config, ... }:

{
  config = {
    programs.chromium = {
      enable = true;
      package = config.lib.test.mkStubPackage {
        name = "chromium-test";
        buildScript = ''
          mkdir -p $out/bin
          # Mock chromium package that supports override with commandLineArgs
          cat > $out/bin/chromium << 'EOF'
          #!/bin/sh
          echo "chromium called with: $@"
          EOF
          chmod +x $out/bin/chromium
        '';
        extraAttrs = {
          override =
            args:
            config.lib.test.mkStubPackage {
              name = "chromium-with-args";
              buildScript = ''
                mkdir -p $out/bin
                cat > $out/bin/chromium << 'EOF'
                #!/bin/sh
                echo "chromium with args: ${args.commandLineArgs or ""} $@"
                EOF
                chmod +x $out/bin/chromium
              '';
            };
        };
      };
      commandLineArgs = [
        "--enable-logging=stderr"
        "--ignore-gpu-blocklist"
        "--disable-web-security"
      ];
    };

    nmt.script = ''
      # Test that the wrapped chromium package is present
      assertFileExists home-path/bin/chromium

      # The package should be overridden with command line args
      # This is tested by the package override functionality
    '';
  };
}
