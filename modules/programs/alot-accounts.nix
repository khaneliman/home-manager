pkgs:
{ config, lib, ... }: {
  options.alot = {
    sendMailCommand = lib.mkOption {
      type = with lib.types; nullOr str;
      description = ''
        Command to send a mail. If msmtp is enabled for the account,
        then this is set to
        {command}`msmtpq --read-envelope-from --read-recipients`.
      '';
    };

    contactCompletion = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {
        type = "shellcommand";
        command =
          "'${pkgs.notmuch}/bin/notmuch address --format=json --output=recipients  date:6M..'";
        regexp = "'\\[?{" + ''
          "name": "(?P<name>.*)", "address": "(?P<email>.+)", "name-addr": ".*"''
          + "}[,\\]]?'";
        shellcommand_external_filtering = "False";
      };
      example = lib.literalExpression ''
        {
          type = "shellcommand";
          command = "abook --mutt-query";
          regexp = "'^(?P<email>[^@]+@[^\t]+)\t+(?P<name>[^\t]+)'";
          ignorecase = "True";
        }
      '';
      description = ''
        Contact completion configuration as expected per alot.
        See [alot's wiki](http://alot.readthedocs.io/en/latest/configuration/contacts_completion.html) for
        explanation about possible values.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra settings to add to this Alot account configuration.
      '';
    };
  };

  config = lib.mkIf config.notmuch.enable {
    alot.sendMailCommand = lib.mkOptionDefault (if config.msmtp.enable then
      "msmtpq --read-envelope-from --read-recipients"
    else
      null);
  };
}
