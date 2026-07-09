{
  home.file."foo/bar".text = "bar";

  nmt.script = ''
    bashPath="$(sed -n '1s/^#!//p' "$TESTED/activate")"
    checkLinkTargets="$(
      grep -o '/nix/store/[0-9a-z]*-check-link-targets.sh' "$TESTED/activate" \
        | head -n 1
    )"

    home="$(mktemp -d)"
    log="$(mktemp)"
    ln -s /nonexistent/parent "$home/foo"

    if HOME="$home" "$bashPath" "$checkLinkTargets" \
        "$TESTED/home-files" "$TESTED/home-files/foo/bar" \
        > "$log" 2>&1; then
      fail "Expected dangling parent symlink to fail collision check."
    fi

    if ! grep -Fq \
        "Existing path '$home/foo' would block creating '$home/foo/bar'" \
        "$log"; then
      cat "$log"
      fail "Expected collision check to report dangling parent symlink."
    fi
  '';
}
