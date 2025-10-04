#!/bin/bash
# Unified Update System - Consolidated from fragmented scripts
# Combines: update-system.sh + simple-update.sh features

# Colors
RED='\033[31m'
ORANGE='\033[38;5;208m'
YELLOW='\033[33m'
GREEN='\033[32m'
NC='\033[0m'

LOGFILE="$HOME/.claude/update-system.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

# Input validation
if [[ -n "$1" && ! "$1" =~ ^(check|status|count|safe|low|high|system|critical|all|demo|sim|simulate)$ ]]; then
    echo "Usage: .update [check|safe|high|critical|all|count|demo]"
    echo "  .update / .update check  - Show categorized update status"
    echo "  .update safe             - Update non-critical packages only"
    echo "  .update high             - Update system/kernel packages"
    echo "  .update critical         - Update security packages only"
    echo "  .update all              - Update everything"
    echo "  .update count            - Quick count for status line"
    echo "  .update demo             - Simulation demo (no actual updates)"
    exit 1
fi

# Quick count for status line integration
if [[ "$1" == "count" ]]; then
    apt_count=$(timeout 2s apt list --upgradable 2>/dev/null | grep -vc "^Listing" || echo "0")
    pip_count=$(timeout 2s pip list --outdated 2>/dev/null | tail -n +3 | wc -l || echo "0")
    snap_count=$(timeout 2s snap refresh --list 2>/dev/null | grep -vc "^All snaps" || echo "0")
    total=$((apt_count + pip_count + snap_count))
    echo "$total"
    exit 0
fi

# ASCII Monolith branding
show_branding() {
    echo -e "${ORANGE}"
    cat << 'EOF'
    ███╗   ███╗ ██████╗ ███╗   ██╗ ██████╗ ██╗     ██╗████████╗██╗  ██╗
    ████╗ ████║██╔═══██╗████╗  ██║██╔═══██╗██║     ██║╚══██╔══╝██║  ██║
    ██╔████╔██║██║   ██║██╔██╗ ██║██║   ██║██║     ██║   ██║   ███████║
    ██║╚██╔╝██║██║   ██║██║╚██╗██║██║   ██║██║     ██║   ██║   ██╔══██║
    ██║ ╚═╝ ██║╚██████╔╝██║ ╚████║╚██████╔╝███████╗██║   ██║   ██║  ██║
    ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝   ╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "                    ${GREEN}🗿 System Update Manager${NC}"
    echo ""
}

# Progress bar function
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))

    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' '-'
    printf "] %3d%%" "$percentage"
}

# Categorized status check
show_status() {
    show_branding
    echo "🔄 SYSTEM UPDATE STATUS"
    echo "======================"
    echo ""

    local has_updates=0

    # APT updates with categorization
    if apt_list=$(apt list --upgradable 2>&1 | grep -v "^Listing"); then
        if [[ -n "$apt_list" ]]; then
            has_updates=1
            critical=$(echo "$apt_list" | grep -Ec "security|openssh|openssl")
            high=$(echo "$apt_list" | grep -Ec "systemd|kernel|linux-image|linux-libc")
            total=$(echo "$apt_list" | wc -l)
            other=$((total - critical - high))

            echo "📦 APT: $total packages"
            [[ $critical -gt 0 ]] && echo -e "  ${RED}🔴 $critical critical (security)${NC}"
            [[ $high -gt 0 ]] && echo -e "  ${ORANGE}🟠 $high high (system/kernel)${NC}"
            [[ $other -gt 0 ]] && echo -e "  ${GREEN}🟢 $other low priority${NC}"
        else
            echo -e "${GREEN}✅ APT packages up to date${NC}"
        fi
    else
        echo "⚠️  APT: Error checking updates"
    fi

    # Snap updates
    if snap_list=$(snap refresh --list 2>&1 | grep -v "^All snaps"); then
        if [[ -n "$snap_list" ]]; then
            has_updates=1
            snap_count=$(echo "$snap_list" | wc -l)
            echo "📦 Snap: $snap_count packages"
        else
            echo -e "${GREEN}✅ Snap packages up to date${NC}"
        fi
    else
        echo "⚠️  Snap: Not installed or error"
    fi

    # Flatpak updates
    if command -v flatpak &> /dev/null; then
        if flatpak_list=$(flatpak remote-ls --updates 2>&1); then
            if [[ -n "$flatpak_list" ]]; then
                has_updates=1
                flatpak_count=$(echo "$flatpak_list" | wc -l)
                echo "📦 Flatpak: $flatpak_count apps"
            else
                echo -e "${GREEN}✅ Flatpak apps up to date${NC}"
            fi
        else
            echo "⚠️  Flatpak: Not configured"
        fi
    fi

    # NPM global updates
    if command -v npm &> /dev/null; then
        if npm_list=$(npm outdated -g --depth=0 2>&1 | tail -n +2); then
            if [[ -n "$npm_list" ]]; then
                has_updates=1
                npm_count=$(echo "$npm_list" | wc -l)
                echo "📦 NPM Global: $npm_count packages"
            else
                echo -e "${GREEN}✅ NPM packages up to date${NC}"
            fi
        else
            echo "⚠️  NPM: Error checking"
        fi
    fi

    # PIP updates
    if command -v pip &> /dev/null; then
        echo -ne "🐍 Checking PIP packages... "
        if pip_list=$(pip list --outdated 2>&1 | tail -n +3); then
            if [[ -n "$pip_list" ]]; then
                has_updates=1
                pip_count=$(echo "$pip_list" | wc -l)
                echo -e "\r🐍 PIP: $pip_count packages          "
            else
                echo -e "\r${GREEN}✅ PIP packages up to date${NC}     "
            fi
        else
            echo -e "\r⚠️  PIP: Error checking          "
        fi
    fi

    echo ""
    if [[ $has_updates -eq 1 ]]; then
        while true; do
            echo -e "${YELLOW}📋 AVAILABLE COMMANDS:${NC}"
            echo -e "  ${GREEN}safe${NC}       - Update low-risk packages only"
            echo -e "  ${ORANGE}high${NC}       - Update system/kernel packages"
            echo -e "  ${RED}critical${NC}   - Update security packages only"
            echo -e "  ${YELLOW}all${NC}        - Update everything"
            echo -e "  ${YELLOW}demo${NC}       - Run simulation (no actual updates)"
            echo -e "  ${YELLOW}exit${NC}       - Exit update manager"
            echo ""
            read -e -p "$(echo -e ${ORANGE}🗿 update${NC}\ ❯\ )" user_command

            case "$user_command" in
                safe|low|high|system|critical|security|all)
                    apply_updates "$user_command"
                    echo ""
                    ;;
                demo|sim|simulate)
                    run_demo
                    echo ""
                    ;;
                exit|quit|q)
                    echo -e "${YELLOW}Exiting update manager...${NC}"
                    break
                    ;;
                "")
                    echo -e "${YELLOW}Exiting update manager...${NC}"
                    break
                    ;;
                *)
                    echo -e "${RED}Unknown command: $user_command${NC}"
                    echo -e "Try: safe, high, critical, all, demo, or exit"
                    echo ""
                    ;;
            esac
        done
    else
        echo -e "${GREEN}✅ All systems up to date${NC}"
    fi

    # Reboot detection
    if [[ -f /var/run/reboot-required ]]; then
        echo -e "${ORANGE}⚠️  Reboot required${NC}"
    fi
}

# Simulate progress for demo
simulate_progress() {
    local task="$1"
    local steps=20
    echo ""
    echo -e "${ORANGE}$task${NC}"
    for i in $(seq 1 $steps); do
        progress_bar $i $steps
        sleep 0.05
    done
    echo ""
}

# Apply updates with filtering
apply_updates() {
    local mode="$1"
    local errors=0

    show_branding
    log "Starting $mode updates..."

    case "$mode" in
        "safe"|"low")
            echo -e "${GREEN}🟢 Updating safe packages...${NC}"
            echo ""

            # APT safe updates (exclude critical system packages)
            echo -e "${ORANGE}📦 Checking APT repositories...${NC}"
            if sudo apt update; then
                safe_packages=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | grep -Ev "systemd|kernel|linux-image|openssh|openssl" | cut -d'/' -f1 | tr '\n' ' ')
                if [[ -n "$safe_packages" ]]; then
                    if sudo apt upgrade -y "$safe_packages"; then
                        log "Safe APT updates completed"
                        echo -e "${GREEN}✅ APT safe updates completed${NC}"
                    else
                        log "ERROR: Safe APT updates failed"
                        echo -e "${RED}❌ APT updates failed${NC}"
                        ((errors++))
                    fi
                fi
            fi

            # PIP safe update
            if command -v pip &> /dev/null; then
                pip install --upgrade pip >/dev/null 2>&1 && log "PIP upgraded"
            fi
            ;;

        "high"|"system")
            echo -e "${ORANGE}🟠 Updating high priority packages...${NC}"

            if sudo apt update; then
                high_packages=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | grep -E "systemd|kernel|linux-image|linux-libc" | cut -d'/' -f1 | tr '\n' ' ')
                if [[ -n "$high_packages" ]]; then
                    if sudo apt upgrade -y "$high_packages"; then
                        log "High priority APT updates completed"
                        echo -e "${GREEN}✅ High priority updates completed${NC}"
                    else
                        log "ERROR: High priority updates failed"
                        echo -e "${RED}❌ High priority updates failed${NC}"
                        ((errors++))
                    fi
                fi
            fi
            ;;

        "critical"|"security")
            echo -e "${RED}🔴 Updating critical security packages...${NC}"

            if sudo apt update; then
                critical_packages=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | grep -E "security|openssh|openssl" | cut -d'/' -f1 | tr '\n' ' ')
                if [[ -n "$critical_packages" ]]; then
                    if sudo apt upgrade -y "$critical_packages"; then
                        log "Critical security updates completed"
                        echo -e "${GREEN}✅ Critical updates completed${NC}"
                    else
                        log "ERROR: Critical updates failed"
                        echo -e "${RED}❌ Critical updates failed${NC}"
                        ((errors++))
                    fi
                else
                    echo -e "${GREEN}✅ No critical updates available${NC}"
                fi
            fi
            ;;

        "all")
            echo -e "${YELLOW}🚀 Updating all packages...${NC}"

            # APT all
            if sudo apt update && sudo apt upgrade -y; then
                log "APT all updates completed"
                echo -e "${GREEN}✅ APT updates completed${NC}"
            else
                log "ERROR: APT updates failed"
                echo -e "${RED}❌ APT updates failed${NC}"
                ((errors++))
            fi

            # Snap
            if sudo snap refresh 2>/dev/null; then
                log "Snap updates completed"
                echo -e "${GREEN}✅ Snap updates completed${NC}"
            else
                log "WARNING: Snap updates failed or not installed"
            fi

            # Flatpak
            if command -v flatpak &> /dev/null; then
                if flatpak update -y 2>/dev/null; then
                    log "Flatpak updates completed"
                    echo -e "${GREEN}✅ Flatpak updates completed${NC}"
                else
                    log "WARNING: Flatpak updates failed"
                fi
            fi

            # NPM
            if command -v npm &> /dev/null; then
                if npm update -g 2>/dev/null; then
                    log "NPM global updates completed"
                    echo -e "${GREEN}✅ NPM updates completed${NC}"
                else
                    log "WARNING: NPM updates failed"
                fi
            fi

            # PIP
            if command -v pip &> /dev/null; then
                pip install --upgrade pip >/dev/null 2>&1 && log "PIP upgraded"
            fi
            ;;
    esac

    echo ""
    if [[ $errors -eq 0 ]]; then
        log "Updates completed successfully"
        echo -e "${GREEN}✅ Updates complete${NC}"
    else
        log "ERROR: Updates completed with $errors error(s)"
        echo -e "${RED}⚠️  Updates completed with $errors error(s)${NC}"
        exit 1
    fi

    # Reboot check
    if [[ -f /var/run/reboot-required ]]; then
        echo -e "${ORANGE}⚠️  Reboot required${NC}"
    else
        echo -e "${GREEN}✅ No reboot needed${NC}"
    fi
}

# Demo/Simulation mode
run_demo() {
    show_branding
    echo -e "${YELLOW}🎬 SIMULATION MODE - No actual updates will be applied${NC}"
    echo ""

    simulate_progress "📡 Checking APT repositories..."
    echo -e "${GREEN}✅ Found 9 packages${NC}"

    simulate_progress "🔍 Analyzing package dependencies..."
    echo -e "${GREEN}✅ Dependencies resolved${NC}"

    simulate_progress "⬇️  Downloading packages (2.3 MB)..."
    echo -e "${GREEN}✅ Download complete${NC}"

    simulate_progress "📦 Installing safe packages..."
    echo -e "${GREEN}✅ 9 packages installed${NC}"

    simulate_progress "📦 Refreshing Snap packages..."
    echo -e "${GREEN}✅ 2 snap packages updated${NC}"

    simulate_progress "🐍 Upgrading PIP..."
    echo -e "${GREEN}✅ PIP upgraded${NC}"

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ Simulation Complete!              ║${NC}"
    echo -e "${GREEN}║                                        ║${NC}"
    echo -e "${GREEN}║  Ready to run: .update safe           ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
}

# Main logic
case "${1:-check}" in
    "check"|"status"|"")
        show_status
        ;;
    "demo"|"sim"|"simulate")
        run_demo
        ;;
    "safe"|"low"|"high"|"system"|"critical"|"security"|"all")
        apply_updates "$1"
        ;;
    *)
        echo "Unknown command: $1"
        exit 1
        ;;
esac
