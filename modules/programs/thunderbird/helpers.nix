{
  config,
  lib,
  cfg,
  isDarwin,
  moduleName,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    filter
    mapAttrsToList
    optionalAttrs
    optionalString
    ;

  # The extensions path shared by all profiles.
  extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

  addId = map (a: a // { id = builtins.hashString "sha256" a.name; });

  enabledEmailAccounts = filter (a: a.enable && a.thunderbird.enable) (
    attrValues config.accounts.email.accounts
  );
  enabledEmailAccountsWithId = addId enabledEmailAccounts;

  enabledCalendarAccounts = filter (a: a.thunderbird.enable) (
    attrValues config.accounts.calendar.accounts
  );
  enabledCalendarAccountsWithId = addId enabledCalendarAccounts;

  enabledContactAccounts = filter (a: a.thunderbird.enable) (
    attrValues config.accounts.contact.accounts
  );
  enabledContactAccountsWithId = addId enabledContactAccounts;

  thunderbirdConfigPath = if isDarwin then "Library/Thunderbird" else ".thunderbird";

  thunderbirdProfilesPath =
    if isDarwin then "${thunderbirdConfigPath}/Profiles" else thunderbirdConfigPath;

  profilesWithId = lib.imap0 (i: v: v // { id = toString i; }) (attrValues cfg.profiles);

  profilesIni =
    lib.foldl lib.recursiveUpdate
      {
        General = {
          StartWithLastProfile = 1;
        }
        // lib.optionalAttrs (cfg.profileVersion != null) {
          Version = cfg.profileVersion;
        };
      }
      (
        lib.flip map profilesWithId (profile: {
          "Profile${profile.id}" = {
            Name = profile.name;
            Path = if isDarwin then "Profiles/${profile.name}" else profile.name;
            IsRelative = 1;
            Default = if profile.isDefault then 1 else 0;
          };
        })
      );

  getId =
    account: address:
    if address == account.address then
      account.id
    else
      (builtins.hashString "sha256" (
        if builtins.isString address then address else (address.address + address.realName)
      ));

  thunderbirdAuthMethods = {
    anonymous = 1;
    clear = 3;
    cram_md5 = 4;
    digest_md5 = 4;
    gssapi = 5;
    login = 3;
    ntlm = 6;
    plain = 3;
    xoauth2 = 10;
  };

  toThunderbirdAuthMethod =
    authentication: if authentication == null then 3 else thunderbirdAuthMethods.${authentication} or 3;

  authMethodWarning =
    name: authentication:
    lib.optional (authentication != null && !builtins.hasAttr authentication thunderbirdAuthMethods) ''
      ${moduleName}: accounts.email.accounts.${name} uses authentication method
      '${authentication}', which Thunderbird does not support directly. Falling back
      to password-based authentication.
    '';

  unsupportedAuthMethodWarnings =
    account:
    let
      aliasWarnings =
        alias:
        lib.optionals (builtins.isAttrs alias && alias.smtp != null && alias.smtp != account.smtp) (
          authMethodWarning "${account.name}.aliases.${alias.address}.smtp" alias.smtp.authentication
        );
    in
    lib.optionals (account.imap != null) (
      authMethodWarning "${account.name}.imap" account.imap.authentication
    )
    ++ lib.optionals (account.smtp != null) (
      authMethodWarning "${account.name}.smtp" account.smtp.authentication
    )
    ++ lib.optionals (account.ews != null) (
      authMethodWarning "${account.name}.ews" account.ews.authentication
    )
    ++ lib.concatMap aliasWarnings account.aliases;

  toThunderbirdIdentity =
    account: address:
    # For backwards compatibility, the primary address reuses the account ID.
    let
      id = getId account address;
      addressIsString = builtins.isString address;
      identity = if addressIsString then account else address // { inherit id; };
    in
    {
      "mail.identity.id_${id}.fullName" = identity.realName;
      "mail.identity.id_${id}.useremail" = if addressIsString then address else address.address;
      "mail.identity.id_${id}.valid" = true;
      "mail.identity.id_${id}.htmlSigText" =
        if identity.signature.showSignature == "none" then "" else identity.signature.text;
    }
    // optionalAttrs identity.signature.htmlFormat {
      "mail.identity.id_${id}.htmlSigFormat" = true;
    }
    // optionalAttrs (identity.gpg != null) {
      "mail.identity.id_${id}.attachPgpKey" = false;
      "mail.identity.id_${id}.autoEncryptDrafts" = true;
      "mail.identity.id_${id}.e2etechpref" = 0;
      "mail.identity.id_${id}.encryptionpolicy" = if identity.gpg.encryptByDefault then 2 else 0;
      "mail.identity.id_${id}.is_gnupg_key_id" = true;
      "mail.identity.id_${id}.last_entered_external_gnupg_key_id" = identity.gpg.key;
      "mail.identity.id_${id}.openpgp_key_id" = identity.gpg.key;
      "mail.identity.id_${id}.protectSubject" = true;
      "mail.identity.id_${id}.sign_mail" = identity.gpg.signByDefault;
    }
    // optionalAttrs (identity.smtp != null) {
      "mail.identity.id_${id}.smtpServer" = "smtp_${identity.id}";
    }
    // optionalAttrs (identity.smtp == null && account.ews != null) {
      "mail.identity.id_${id}.smtpServer" = "ews_${account.id}";
    }
    // account.thunderbird.perIdentitySettings id;

  toThunderbirdSMTP =
    account: address:
    let
      id = getId account address;
      addressIsString = builtins.isString address;
    in
    optionalAttrs (!addressIsString && address.smtp != null) {
      "mail.smtpserver.smtp_${id}.authMethod" = toThunderbirdAuthMethod address.smtp.authentication;
      "mail.smtpserver.smtp_${id}.hostname" = address.smtp.host;
      "mail.smtpserver.smtp_${id}.port" = if address.smtp.port != null then address.smtp.port else 587;
      "mail.smtpserver.smtp_${id}.try_ssl" =
        if !address.smtp.tls.enable then
          0
        else if address.smtp.tls.useStartTls then
          2
        else
          3;
      "mail.smtpserver.smtp_${id}.username" = address.userName;
    };

  toThunderbirdAccount =
    account: profile:
    let
      inherit (account) id;
      addresses = [ account.address ] ++ account.aliases;
    in
    {
      "mail.account.account_${id}.identities" = concatStringsSep "," (
        map (address: "id_${getId account address}") addresses
      );
      "mail.account.account_${id}.server" = "server_${id}";
    }
    // optionalAttrs account.primary {
      "mail.accountmanager.defaultaccount" = "account_${id}";
    }
    // optionalAttrs (account.imap != null) {
      "mail.server.server_${id}.directory" = "${thunderbirdProfilesPath}/${profile.name}/ImapMail/${id}";
      "mail.server.server_${id}.directory-rel" = "[ProfD]ImapMail/${id}";
      "mail.server.server_${id}.hostname" = account.imap.host;
      "mail.server.server_${id}.login_at_startup" = true;
      "mail.server.server_${id}.name" = account.name;
      "mail.server.server_${id}.port" = if account.imap.port != null then account.imap.port else 143;
      "mail.server.server_${id}.socketType" =
        if !account.imap.tls.enable then
          0
        else if account.imap.tls.useStartTls then
          2
        else
          3;
      "mail.server.server_${id}.type" = "imap";
      "mail.server.server_${id}.userName" = account.userName;
    }
    // optionalAttrs (account.imap != null && account.imap.authentication != null) {
      "mail.server.server_${id}.authMethod" = toThunderbirdAuthMethod account.imap.authentication;
    }
    // optionalAttrs (account.smtp != null) {
      "mail.smtpserver.smtp_${id}.authMethod" = toThunderbirdAuthMethod account.smtp.authentication;
      "mail.smtpserver.smtp_${id}.hostname" = account.smtp.host;
      "mail.smtpserver.smtp_${id}.port" = if account.smtp.port != null then account.smtp.port else 587;
      "mail.smtpserver.smtp_${id}.try_ssl" =
        if !account.smtp.tls.enable then
          0
        else if account.smtp.tls.useStartTls then
          2
        else
          3;
      "mail.smtpserver.smtp_${id}.username" = account.userName;
    }
    // optionalAttrs (account.ews != null) {
      "mail.smtpserver.ews_${id}.type" = "ews";
      "mail.outgoingserver.ews_${id}.auth_method" = toThunderbirdAuthMethod account.ews.authentication;
      "mail.outgoingserver.ews_${id}.description" = account.name;
      "mail.outgoingserver.ews_${id}.ews_url" = account.ews.serviceDescriptionURL;
      "mail.outgoingserver.ews_${id}.key" = "ews_${id}";
      "mail.outgoingserver.ews_${id}.username" = account.userName;

      "mail.server.server_${id}.directory" = "${thunderbirdProfilesPath}/${profile.name}/Mail/${id}";
      "mail.server.server_${id}.directory-rel" = "[ProfD]Mail/${id}";
      "mail.server.server_${id}.hostname" = account.ews.host;
      "mail.server.server_${id}.ews_url" = account.ews.serviceDescriptionURL;
      "mail.server.server_${id}.login_at_startup" = true;
      "mail.server.server_${id}.name" = account.name;
      "mail.server.server_${id}.port" = 443;
      "mail.server.server_${id}.socketType" =
        if !account.ews.tls.enable then
          0
        else if account.ews.tls.useStartTls then
          2
        else
          3;
      "mail.server.server_${id}.type" = "ews";
      "mail.server.server_${id}.userName" = account.userName;
    }
    // optionalAttrs (account.ews != null && account.ews.authentication != null) {
      "mail.server.server_${id}.authMethod" = toThunderbirdAuthMethod account.ews.authentication;
    }
    // builtins.foldl' (a: b: a // b) { } (map (address: toThunderbirdSMTP account address) addresses)
    // optionalAttrs (account.smtp != null && account.primary) {
      "mail.smtp.defaultserver" = "smtp_${id}";
    }
    // optionalAttrs (account.smtp == null && account.ews != null && account.primary) {
      "mail.smtp.defaultserver" = "ews_${id}";
    }
    // builtins.foldl' (a: b: a // b) { } (
      map (address: toThunderbirdIdentity account address) addresses
    )
    // account.thunderbird.settings id;

  toThunderbirdCalendar =
    calendar: _:
    let
      inherit (calendar) id;
    in
    {
      "calendar.registry.calendar_${id}.name" = calendar.name;
      "calendar.registry.calendar_${id}.calendar-main-in-composite" = true;
      "calendar.registry.calendar_${id}.cache.enabled" = true;
    }
    // optionalAttrs (calendar.remote == null) {
      "calendar.registry.calendar_${id}.type" = "storage";
      "calendar.registry.calendar_${id}.uri" = "moz-storage-calendar://";
    }
    // optionalAttrs (calendar.remote != null) {
      "calendar.registry.calendar_${id}.type" =
        if calendar.remote.type == "http" then "ics" else calendar.remote.type;
      "calendar.registry.calendar_${id}.uri" = calendar.remote.url;
      "calendar.registry.calendar_${id}.username" = calendar.remote.userName;
    }
    // optionalAttrs calendar.primary {
      "calendar.registry.calendar_${id}.calendar-main-default" = true;
    }
    // optionalAttrs calendar.thunderbird.readOnly {
      "calendar.registry.calendar_${id}.readOnly" = true;
    }
    // optionalAttrs (calendar.thunderbird.color != "") {
      "calendar.registry.calendar_${id}.color" = calendar.thunderbird.color;
    }
    // calendar.thunderbird.settings id;

  toThunderbirdContact =
    contact: _:
    let
      inherit (contact) id;
    in
    lib.filterAttrs (_n: v: v != null) (
      {
        "ldap_2.servers.contact_${id}.description" = contact.name;
        "ldap_2.servers.contact_${id}.filename" = "contact_${id}.sqlite"; # this is needed for carddav to work
      }
      // optionalAttrs (contact.remote == null) {
        "ldap_2.servers.contact_${id}.dirType" = 101; # dirType 101 for local address book
      }
      // optionalAttrs (contact.remote != null && contact.remote.type == "carddav") {
        "ldap_2.servers.contact_${id}.dirType" = 102; # dirType 102 for CardDAV
        "ldap_2.servers.contact_${id}.carddav.url" = contact.remote.url;
        "ldap_2.servers.contact_${id}.carddav.username" = contact.remote.userName;
        "ldap_2.servers.contact_${id}.carddav.token" = contact.thunderbird.token;
      }
    );

  toThunderbirdFeed =
    feed: profile:
    let
      inherit (feed) id;
    in
    {
      "mail.account.account_${id}.server" = "server_${id}";
      "mail.server.server_${id}.name" = feed.name;
      "mail.server.server_${id}.type" = "rss";
      "mail.server.server_${id}.directory" =
        "${thunderbirdProfilesPath}/${profile.name}/Mail/Feeds-${id}";
      "mail.server.server_${id}.directory-rel" = "[ProfD]Mail/Feeds-${id}";
      "mail.server.server_${id}.hostname" = "Feeds-${id}";
    };

  mkUserJs = prefs: extraPrefs: ''
    // Generated by Home Manager.

    ${lib.concatStrings (
      mapAttrsToList (name: value: ''
        user_pref("${name}", ${builtins.toJSON value});
      '') prefs
    )}
    ${extraPrefs}
  '';

  mkFilterToIniString =
    f:
    if f.text == null then
      ''
        name="${f.name}"
        enabled="${if f.enabled then "yes" else "no"}"
        type="${f.type}"
        action="${f.action}"
      ''
      + optionalString (f.actionValue != null) ''
        actionValue="${f.actionValue}"
      ''
      + ''
        condition="${f.condition}"
      ''
      + optionalString (f.extraConfig != null) f.extraConfig
    else
      f.text;

  mkFilterListToIni =
    filters:
    ''
      version="9"
      logging="no"
    ''
    + lib.concatStrings (map mkFilterToIniString filters);

  getAccountsForProfile =
    profileName: accounts:
    filter (
      a: a.thunderbird.profiles == [ ] || lib.any (p: p == profileName) a.thunderbird.profiles
    ) accounts;
in
{
  inherit
    addId
    enabledCalendarAccounts
    enabledCalendarAccountsWithId
    enabledContactAccounts
    enabledContactAccountsWithId
    enabledEmailAccounts
    enabledEmailAccountsWithId
    extensionPath
    getAccountsForProfile
    getId
    mkFilterListToIni
    mkUserJs
    profilesIni
    profilesWithId
    thunderbirdConfigPath
    thunderbirdProfilesPath
    toThunderbirdAccount
    toThunderbirdCalendar
    toThunderbirdContact
    toThunderbirdFeed
    unsupportedAuthMethodWarnings
    ;
}
