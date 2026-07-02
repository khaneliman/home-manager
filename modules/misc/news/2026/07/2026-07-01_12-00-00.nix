{
  time = "2026-07-01T12:00:00+00:00";
  condition = true;
  message = ''
    Warnings and assertions can now point at the configuration files that
    define the options causing them. Modules may attach `relatedOptions`
    to entries in {option}`warnings` and {option}`assertions`; Home
    Manager appends "Caused by definitions in <files>." with the user's
    defining files when displaying them.

    Platform assertions created via `lib.hm.assertions.assertPlatform`
    and the deprecation warning helpers in `lib.hm.deprecations` do this
    automatically.
  '';
}
