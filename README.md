# 🗿 Monolith System Updater

**Version 1.0.0** - A consolidated, interactive system update manager for Linux

## Overview

Monolith System Updater is a unified update management tool that consolidates package updates across multiple package managers (APT, Snap, Flatpak, NPM, PIP) with color-coded risk assessment and interactive workflow.

## Features

### 🎯 Multi-Package Manager Support
- **APT** (Debian/Ubuntu system packages)
- **Snap** (Snap packages)
- **Flatpak** (Flatpak applications)
- **NPM** (Node.js global packages)
- **PIP** (Python packages)

### 🚦 Color-Coded Risk Categories
- 🔴 **Critical** (security): openssh, openssl, security patches
- 🟠 **High** (system/kernel): systemd, linux-image, kernel updates
- 🟢 **Safe** (low-risk): applications, libraries, UI packages

### ⚡ Smart Update Modes
- `safe` - Update low-risk packages only
- `high` - Update system/kernel packages
- `critical` - Update security packages only
- `all` - Update everything
- `demo` - Simulation mode (no actual updates)

### 🎨 Interactive UX
- **Context-aware prompt**: `🗿 update ❯` shows you're in the updater
- **Loop-back workflow**: Commands return to menu instead of exiting
- **Clear exit paths**: `exit`, `quit`, `q`, or press Enter
- **Loading indicators**: Real-time feedback during slow operations
- **ASCII-safe progress bars**: Works across all terminals

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/monolith-updater.git
cd monolith-updater

# Install to ~/.claude directory
cp .update ~/.claude/dot-update.sh
cp update-production.sh ~/.claude/update-production.sh
chmod +x ~/.claude/dot-update.sh ~/.claude/update-production.sh

# Add alias to ~/.bashrc
echo "alias .update='~/.claude/dot-update.sh'" >> ~/.bashrc
source ~/.bashrc
```

### Verify Installation

```bash
.update
# Should display the Monolith System Updater interface
```

## Usage

### Basic Commands

```bash
# Check update status (default)
.update

# Run simulation/demo
.update demo

# Apply updates by category
.update safe       # Low-risk updates only
.update high       # System/kernel updates
.update critical   # Security updates only
.update all        # Everything

# Quick count (for status line integration)
.update count
```

### Interactive Mode

When you run `.update`, you enter an interactive session:

```
📋 AVAILABLE COMMANDS:
  safe       - Update low-risk packages only
  high       - Update system/kernel packages
  critical   - Update security packages only
  all        - Update everything
  demo       - Run simulation (no actual updates)
  exit       - Exit update manager

🗿 update ❯
```

Type commands directly (no `.update` prefix needed in interactive mode).

## Architecture

### Files Structure

```
monolith-updater/
├── .update                  # Entry point wrapper (110 bytes)
├── update-production.sh     # Main implementation (15KB)
├── README.md               # This file
└── VERSION                 # Version history and journey documentation
```

### How It Works

1. **`.update`** - Wrapper script that calls the main implementation
2. **`update-production.sh`** - Contains all logic:
   - Package detection and categorization
   - Interactive menu system
   - Update execution with progress feedback
   - Error handling and logging

### Logging

All operations are logged to: `~/.claude/update-system.log`

```bash
# View logs
tail -f ~/.claude/update-system.log
```

## Security Features

✅ **Input validation**: All user input validated against allowed patterns
✅ **Quoted variables**: Prevents globbing and word splitting
✅ **Error capture**: Comprehensive error handling with logging
✅ **Shellcheck validated**: Passes bash linting standards
✅ **No silent failures**: All errors logged and reported

## Design Principles

This project follows **Monolith Protocol** principles:

### 1. Anti-Fragmentation
- **State-check-first**: Search for existing tools before building new ones
- **Consolidation over duplication**: Flags/subcommands instead of separate scripts
- **Single source of truth**: One implementation, multiple access points

### 2. Interactive CLI Best Practices
- **Context awareness**: Distinctive prompts show app context
- **Loop-back UX**: Actions return to menu, not terminal
- **Terminal compatibility**: ASCII-safe symbols, universal support

### 3. Anti-Theatre (Evidence-First Development)
- **Real problem validation**: Built to solve actual fragmentation issue
- **Minimal complexity**: 2 files vs 5+ fragmented scripts (60% reduction)
- **Measurable improvements**: Documented efficiency gains

## Troubleshooting

### Updates not showing
```bash
# Refresh package lists first
sudo apt update
.update
```

### Permission errors
```bash
# Ensure scripts are executable
chmod +x ~/.claude/dot-update.sh ~/.claude/update-production.sh
```

### Alias not working
```bash
# Reload bashrc
source ~/.bashrc

# Or check if alias exists
grep ".update" ~/.bashrc
```

## Development History

See [VERSION](VERSION) file for complete development journey from fragmented scripts to consolidated v1.0.

### The Consolidation Story

**Before (The Problem)**:
- 5 fragmented scripts + 2 symlinks
- No interactive UX, exits after each command
- Generic prompts, Unicode rendering issues
- 84KB redundant code, 9x maintenance burden

**After (v1.0)**:
- 2 clean files, single source of truth
- Interactive loop-back UX
- Context-aware prompts (`🗿 update ❯`)
- ASCII-safe, cross-terminal compatible
- 60% fewer files, easier to maintain

## Contributing

This project follows strict anti-fragmentation protocols:

1. **Search first**: Check existing functionality before adding features
2. **Integrate, don't separate**: Add flags/subcommands, not new files
3. **Validate complexity**: Use Gemini validation for >50 line changes
4. **Document learnings**: Update VERSION file with lessons learned

## Credits

Built with **Claude Code (Sonnet 4.5)** following **Monolith Protocol** principles.

Key methodologies applied:
- **State-Check-First Protocol**: Prevent fragmentation through discovery
- **SOQM Architecture**: Scrape-Once-Query-Many efficiency patterns
- **Gemini Validation**: Multi-perspective security and logic review
- **Interactive CLI Design**: Context awareness and loop-back UX

## License

MIT License - See LICENSE file for details

---

**🗿 Monolith Protocol**: *Consolidate. Simplify. Execute.*
