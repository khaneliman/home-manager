{
  config = {
    programs.java.enable = true;

    nmt.script = ''
      # Test that JAVA_HOME environment variable is set
      hmEnvFile=home-path/etc/profile.d/hm-session-vars.sh
      assertFileContains $hmEnvFile 'JAVA_HOME='
    '';
  };
}
