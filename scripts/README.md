# Home Manager Scripts

This directory contains utility scripts for maintaining and analyzing the Home Manager codebase.

## Test Coverage Analysis

### `generate-test-coverage-report.py`

Automatically generates comprehensive test coverage analysis reports for Home Manager modules.

**Features:**
- Identifies untested service and program modules
- Analyzes module complexity and configuration patterns
- Prioritizes modules by usage importance and technical complexity
- Generates detailed statistics and recommendations
- Suitable for CI integration

**Usage:**
```bash
# Generate report in repository root
python3 scripts/generate-test-coverage-report.py

# Specify custom output file
python3 scripts/generate-test-coverage-report.py --output coverage-report.md

# Use different repository root
python3 scripts/generate-test-coverage-report.py --repo-root /path/to/home-manager
```

**CI Integration Example:**
```yaml
name: Test Coverage Analysis
on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  coverage-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Generate coverage report
        run: python3 scripts/generate-test-coverage-report.py
      
      - name: Check for changes
        run: |
          if git diff --quiet TEST_COVERAGE_GAPS_ANALYSIS.md; then
            echo "No coverage changes detected"
          else
            echo "Coverage analysis updated"
            git diff --stat TEST_COVERAGE_GAPS_ANALYSIS.md
          fi
      
      - name: Create PR for coverage updates
        if: github.event_name == 'schedule'
        uses: peter-evans/create-pull-request@v5
        with:
          title: "chore: update test coverage analysis"
          body: "Automated update of test coverage analysis report"
          branch: update-coverage-analysis
```

**What the script analyzes:**
- Module complexity (lines of code, configuration formats, systemd components)
- Priority levels based on common usage patterns
- Configuration file formats (TOML, YAML, JSON, INI, custom)
- Systemd service patterns (services, timers, sockets)
- Cross-platform requirements (Linux systemd vs Darwin launchd)

**Output includes:**
- Executive summary with coverage statistics
- Prioritized lists of untested modules
- Technical assessment of module characteristics  
- Implementation recommendations organized by priority phases
- Testing patterns and best practices
- Impact analysis and maintenance considerations