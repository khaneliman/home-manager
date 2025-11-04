{
  config = {
    programs.jetbrains-remote.enable = true;

    nmt.script = ''
      assertFileExists home-files/.local/share/JetBrains/RemoteDev/dist
    '';
  };
}
