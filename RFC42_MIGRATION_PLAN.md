# Home Manager RFC42 Settings Style Migration Plan

## Executive Summary

This document outlines a comprehensive plan to migrate home-manager modules to follow RFC42 settings style configuration. RFC42 promotes structural `settings` options over stringly-typed `extraConfig` patterns, providing better modularity, type checking, and maintainability.

### Current State
- **129 modules** identified using non-RFC42 patterns (primarily `extraConfig`)
- **244 modules** already implement RFC42-style `settings` options
- Mixed patterns create inconsistent user experience and maintenance burden

### Goals
1. **Consistency**: Uniform configuration patterns across all modules
2. **Type Safety**: Better validation and error reporting
3. **Maintainability**: Reduced boilerplate and easier updates
4. **User Experience**: Predictable configuration structure

---

## RFC42 Principles Review

### What RFC42 Promotes
- Structural `settings` options using `pkgs.formats` generators
- Freeform types with non-restrictive schemas  
- Use of `lib.generators` for config file creation
- Balanced module options (valuable options as separate options, rest in `settings`)

### What RFC42 Discourages
- String-based `extraConfig` options
- Manual string concatenation for config generation
- Dozens of individual options for every upstream setting
- Hardcoded defaults that can't be overridden

---

## Module Inventory

### HIGH PRIORITY - Popular Programs (Easy Migration)

| Module | File Path | Current Pattern | Migration Complexity | Reason |
|--------|-----------|----------------|---------------------|--------|
| `tmux` | `modules/programs/tmux.nix` | extraConfig + string concat | **Easy** | Very popular, simple config format |
| `vim` | `modules/programs/vim.nix` | Mixed options + extraConfig | **Medium** | Popular, has some settings structure |
| `kitty` | `modules/programs/kitty.nix` | extraConfig | **Easy** | Popular terminal, simple key-value format |
| `git` | `modules/programs/git.nix` | Mixed + extraConfig | **Medium** | Critical tool, complex existing structure |
| `ssh` | `modules/programs/ssh.nix` | extraConfig | **Medium** | Critical tool, security implications |
| `neovim` | `modules/programs/neovim.nix` | extraConfig + complex options | **Hard** | Popular but complex plugin system |
| `qutebrowser` | `modules/programs/qutebrowser.nix` | extraConfig | **Easy** | Python dict-style config |
| `ranger` | `modules/programs/ranger.nix` | extraConfig | **Easy** | Simple rc.conf format |

### HIGH PRIORITY - Core Services

| Module | File Path | Current Pattern | Migration Complexity | Reason |
|--------|-----------|----------------|---------------------|--------|
| `hyprland` | `services/window-managers/hyprland.nix` | extraConfig | **Medium** | Popular WM, growing user base |
| `polybar` | `services/polybar.nix` | extraConfig + string concat | **Medium** | Popular bar, INI-style format |
| `dunst` | `services/dunst.nix` | extraConfig | **Easy** | Notification daemon, simple config |
| `mako` | `services/mako.nix` | extraConfig | **Easy** | Wayland notifications, simple format |
| `picom` | `services/picom.nix` | extraConfig | **Easy** | Compositor, simple config format |

### MEDIUM PRIORITY - Development Tools

| Module | File Path | Current Pattern | Migration Complexity | Reason |
|--------|-----------|----------------|---------------------|--------|
| `helix` | `programs/helix.nix` | extraConfig | **Easy** | Modern editor, TOML config |
| `kakoune` | `programs/kakoune.nix` | extraConfig | **Easy** | Editor, simple config format |
| `irssi` | `programs/irssi.nix` | extraConfig | **Medium** | IRC client, complex config |
| `gh` | `programs/gh.nix` | extraConfig | **Easy** | GitHub CLI, YAML config |

### MEDIUM PRIORITY - Mail/Communication

| Module | File Path | Current Pattern | Migration Complexity | Reason |
|--------|-----------|----------------|---------------------|--------|
| `neomutt` | `programs/neomutt/default.nix` | extraConfig | **Medium** | Mail client, complex options |
| `mbsync` | `programs/mbsync/default.nix` | extraConfig | **Medium** | Mail sync, structured config |
| `msmtp` | `programs/msmtp/default.nix` | extraConfig | **Easy** | SMTP client, simple config |
| `notmuch` | `programs/notmuch/default.nix` | extraConfig | **Easy** | Mail indexer, simple config |

### MEDIUM PRIORITY - Window Managers & Desktop

| Module | File Path | Current Pattern | Migration Complexity | Reason |
|--------|-----------|----------------|---------------------|--------|
| `i3` | `services/window-managers/i3-sway/i3.nix` | extraConfig + options | **Hard** | Complex existing structure |
| `sway` | `services/window-managers/i3-sway/sway.nix` | extraConfig + options | **Hard** | Complex existing structure |
| `bspwm` | `services/window-managers/bspwm/default.nix` | extraConfig | **Medium** | WM with structured config |
| `river` | `services/window-managers/river.nix` | extraConfig | **Medium** | Modern Wayland WM |

### LOW PRIORITY - Specialized Tools

| Module | File Path | Current Pattern | Migration Complexity | Reason |
|--------|-----------|----------------|---------------------|--------|
| `offlineimap` | `programs/offlineimap/default.nix` | extraConfig | **Medium** | Legacy tool, complex config |
| `mopidy` | `services/mopidy.nix` | extraConfig | **Medium** | Music server, plugin system |
| `conky` | `services/conky.nix` | extraConfig | **Easy** | System monitor, Lua config |

---

## Migration Complexity Analysis

### Easy Migration (≤ 2 days)
**Characteristics:**
- Simple key-value configuration formats
- No complex nested structures
- Limited existing options to preserve
- Clear upstream configuration documentation

**Examples:** kitty, dunst, mako, ranger, helix

**Migration Pattern:**
```nix
# Before
programs.kitty.extraConfig = ''
  font_size 12
  background_opacity 0.9
'';

# After  
programs.kitty.settings = {
  font_size = 12;
  background_opacity = 0.9;
};
```

### Medium Migration (3-5 days)
**Characteristics:**
- More complex configuration structures
- Some existing valuable options to preserve
- May require custom format generators
- Multiple configuration files or sections

**Examples:** git, ssh, polybar, neomutt

**Migration Pattern:**
```nix
# Before
programs.git = {
  userName = "user";
  userEmail = "user@example.com";
  extraConfig = ''
    [push]
      default = simple
  '';
};

# After
programs.git = {
  userName = "user";  # Keep valuable options
  userEmail = "user@example.com";
  settings = {
    push.default = "simple";
    # All other config goes here
  };
};
```

### Hard Migration (1-2 weeks)
**Characteristics:**
- Complex existing module structures
- Many existing options to preserve or deprecate
- Plugin systems or extensions
- Multiple configuration formats
- High backward compatibility requirements

**Examples:** neovim, i3/sway, firefox

**Migration Strategy:**
1. Preserve all existing options for backward compatibility
2. Add new `settings` option alongside
3. Gradual deprecation of old patterns
4. Extensive testing required

---

## Backwards Compatibility Strategy

### Phase 1: Additive Changes
- Add `settings` option alongside existing `extraConfig`
- Both options work simultaneously
- No breaking changes
- User education through documentation

### Phase 2: Deprecation Warnings  
- Add deprecation warnings for `extraConfig` usage
- Encourage migration through news entries
- Provide migration examples
- Timeline: 6 months minimum

### Phase 3: Breaking Changes (Optional)
- Remove deprecated `extraConfig` options
- Only for modules where it significantly improves maintenance
- Major version bump consideration
- Extensive migration guide

### Compatibility Helpers

```nix
# Template for backward compatibility
let
  # Merge extraConfig into settings
  mergedSettings = cfg.settings // (
    if cfg.extraConfig != "" then
      lib.warn "programs.example.extraConfig is deprecated, use programs.example.settings instead"
      (parseExtraConfig cfg.extraConfig)
    else {}
  );
in
```

---

## Implementation Templates

### Standard Settings Pattern

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.example;
  settingsFormat = pkgs.formats.toml { }; # or json, yaml, ini, etc.
in
{
  options.programs.example = {
    enable = lib.mkEnableOption "example program";
    
    package = lib.mkPackageOption pkgs "example" { };
    
    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          key = "value";
          section = {
            nested_key = true;
          };
        }
      '';
      description = ''
        Configuration for example program.
        See <https://example.com/docs/config> for available options.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    xdg.configFile."example/config.toml".source = 
      settingsFormat.generate "example-config.toml" cfg.settings;
  };
}
```

### Custom Format Generator

```nix
# For programs with unique config formats
let
  configFormat = {
    type = with lib.types; attrsOf (oneOf [ str int bool (listOf str) ]);
    generate = name: value: pkgs.writeText name (lib.generators.toKeyValue {
      mkKeyValue = key: value: "${key} = ${toString value}";
      listsAsDuplicateKeys = true;
    } value);
  };
in
```

### Freeform Module Pattern

```nix
# For complex configurations needing validation
settings = lib.mkOption {
  type = lib.types.submodule {
    freeformType = settingsFormat.type;
    
    # Declare important options for documentation/validation
    options.port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };
    
    options.log_level = lib.mkOption {
      type = lib.types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
      description = "Logging level";
    };
  };
  default = { };
  description = "Configuration for the program";
};
```

---

## Testing Requirements

### Per-Module Testing
1. **Basic functionality**: Program starts and runs with default settings
2. **Settings validation**: Invalid configurations are rejected
3. **File generation**: Config files are generated correctly
4. **Backward compatibility**: Both old and new patterns work
5. **Integration**: Works with other home-manager modules

### Test Structure Template

```nix
# tests/modules/programs/example/default.nix
{
  basic-settings = ./basic-settings.nix;
  complex-config = ./complex-config.nix;
  backward-compatibility = ./backward-compatibility.nix;
}

# tests/modules/programs/example/basic-settings.nix
{ config, ... }:
{
  programs.example = {
    enable = true;
    settings = {
      key = "value";
      section = {
        nested = true;
      };
    };
  };
  
  test.stubs.example = { };
  
  nmt.script = ''
    assertFileExists home-files/.config/example/config.toml
    assertFileContains home-files/.config/example/config.toml "key = \"value\""
  '';
}
```

---

## Implementation Timeline

### Phase 1: Foundation (Weeks 1-2)
- Document migration patterns
- Create testing infrastructure
- Implement 3-5 easy migrations as examples

### Phase 2: Popular Programs (Weeks 3-6)
- Migrate high-priority programs (tmux, kitty, vim)
- Create migration guides
- Gather user feedback

### Phase 3: Services & WMs (Weeks 7-10)
- Migrate core services (dunst, mako, picom)
- Begin window manager migrations
- Update documentation

### Phase 4: Specialized Tools (Weeks 11-14)
- Migrate remaining programs
- Handle edge cases and complex modules
- Comprehensive testing

### Phase 5: Cleanup (Weeks 15-16)
- Address remaining issues
- Update all documentation
- Prepare news entries

---

## Migration Execution Checklist

### For Each Module:
- [ ] Analyze current configuration pattern
- [ ] Identify appropriate format generator
- [ ] Determine valuable options to preserve
- [ ] Implement new `settings` option
- [ ] Add backward compatibility layer
- [ ] Write comprehensive tests
- [ ] Update documentation and examples
- [ ] Create news entry if needed
- [ ] Test with real-world configurations

### Quality Gates:
- [ ] All existing tests still pass
- [ ] New functionality is well tested
- [ ] Documentation is updated
- [ ] No new deprecation warnings
- [ ] Performance impact is minimal

---

## Risks and Mitigations

### Risk: User Configuration Breakage
**Mitigation:** Maintain backward compatibility for at least 6 months, provide clear migration guides

### Risk: Complex Configuration Edge Cases  
**Mitigation:** Extensive testing with community configurations, gradual rollout

### Risk: Maintenance Overhead During Transition
**Mitigation:** Focus on high-impact modules first, automate testing where possible

### Risk: Format Generator Limitations
**Mitigation:** Custom generators for unique formats, fallback to string generation if needed

---

## Success Metrics

1. **Coverage**: >90% of modules use RFC42 settings pattern
2. **Consistency**: Uniform configuration experience across modules  
3. **Maintainability**: Reduced module complexity and boilerplate
4. **User Adoption**: Community feedback and adoption rates
5. **Quality**: No regressions in functionality or performance

---

## References

- [RFC42 Documentation](https://github.com/NixOS/rfcs/blob/master/rfcs/0042-config-option.md)
- [Home Manager RFC42 Examples](modules/programs/starship.nix)
- [NixOS pkgs.formats Documentation](https://nixos.org/manual/nixos/stable/index.html#sec-settings-options)

---

*This document should be updated as the migration progresses and new patterns emerge.*