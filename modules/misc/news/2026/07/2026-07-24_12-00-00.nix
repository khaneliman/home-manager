{
  time = "2026-07-24T12:00:00+00:00";
  condition = true;
  message = ''
    The generated `hm-session-vars.sh` file is now safe to source multiple
    times.

    Plain `home.sessionVariables` are no longer guarded by
    `__HM_SESS_VARS_SOURCED`, so newly started shells pick up changed values
    after `home-manager switch` without logging out, and shells running under
    terminal multiplexers such as tmux receive the current values.

    Non-empty entries from `home.sessionPath` and
    `home.sessionSearchVariables` are now only prepended when they are not
    already present in the variable. Duplicate entries contributed by merged
    Home Manager modules are added once. This avoids adding another copy when
    the guard variable is lost while the modified values are kept. An entry
    that is already present keeps its current position and is no longer moved
    to the front, so environments that deliberately reorder `PATH` (such as
    `nix develop` or direnv) are left untouched.

    Existing duplicates are not removed. Removing an entry from Home Manager
    configuration also does not remove it from an inherited environment; that
    requires starting with a reset environment. Systemd user services keep the
    existing `environment.d` prepend semantics and may therefore observe
    different ordering or inherited duplicates from shell sessions.

    Note that child shells now re-assert Home Manager session variable
    values: a variable exported manually in an interactive shell is reset to
    its Home Manager value in nested shells. The extra initialization added
    by modules through `home.sessionVariablesExtra` still runs only once per
    session, guarded by `__HM_SESS_VARS_SOURCED`.

    On generic Linux, Bash now reaches `nix.sh` only through this guarded extra
    section instead of sourcing it a second time from `.bashrc`. The existing
    Darwin `TERMINFO_DIRS` opt-out through
    `home.sessionVariables.TERMINFO_DIRS` remains supported.

    Since plain `home.sessionVariables` are re-exported by every shell, a
    value must no longer reference the variable it defines (for example
    `MANPATH = "$HOME/man:$MANPATH"`) as it would grow with every nested
    shell. Use `home.sessionPath` or `home.sessionSearchVariables` for such
    search paths instead.
  '';
}
