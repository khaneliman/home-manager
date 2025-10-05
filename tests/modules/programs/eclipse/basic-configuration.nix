{ pkgs, ... }:
{
  programs.eclipse = {
    enable = true;
    enableLombok = true;
    jvmArgs = [ "-Xmx4g" ];
    plugins = [ pkgs.eclipses.plugins.vrapper ];
  };

  nmt.script = ''
    eclipse_exe=$(readlink -f home-files/.nix-profile/bin/eclipse)
    eclipse_package_path=$(grep -oE '/nix/store/[a-z0-9]{32}-eclipse-with-plugins[^/]*' "$eclipse_exe" | head -n 1)

    assertPathExists "$eclipse_package_path/eclipse"

    ini_file="$eclipse_package_path/eclipse/eclipse.ini"
    assertFileExists "$ini_file"

    assertFileContains "$ini_file" "-Xmx4g"
    assertFileContains "$ini_file" "lombok.jar"

    plugin_dir="$eclipse_package_path/eclipse/plugins"
    assertPathExists "$plugin_dir"

    if ! ls "$plugin_dir" | grep -q 'vrapper'; then
      echo "Vrapper plugin not found in $plugin_dir"
      ls "$plugin_dir"
      exit 1
    fi
  '';
}
