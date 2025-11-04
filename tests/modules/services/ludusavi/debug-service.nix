{ config, ... }:

{
  config = {
    services.ludusavi = {
      enable = true;
    };

    nmt.script = ''
      echo "=== Generated service file ===" >&2
      cat home-files/.config/systemd/user/ludusavi.service >&2
      echo "=== End service file ===" >&2
    '';
  };
}
