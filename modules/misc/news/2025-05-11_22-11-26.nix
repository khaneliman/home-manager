{
  time = "2025-05-12T03:11:26+00:00";
  condition = true;
  message = ''
    Firefox extension permissions can now be restricted

    A new feature has been added to Firefox configuration that allows you to restrict
    the permissions granted to browser extensions. This helps improve security by
    implementing the principle of least privilege for installed extensions.

    Example configuration:

    ```nix
    programs.firefox.profiles.default.extensions.settings = {
      "uBlock0@raymondhill.net" = {
        name = "ublock-origin";  # NUR package name for permission checking
        permissions = [
          "contextMenus"
          "privacy" 
          "storage" 
          "webNavigation"
          "webRequest" 
          "webRequestBlocking"
        ];
      };
    };
    ```

    This feature works with extensions from the NUR rycee.firefox-addons collection
    and will prevent the system from building if an extension requires permissions
    that are not explicitly allowed in your configuration.
  '';
}
