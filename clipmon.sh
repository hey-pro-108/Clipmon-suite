#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export BOLD='\033[1m'
export NC='\033[0m'

source ./init.sh
source ./config.sh
source ./utils.sh
source ./crypto.sh
source ./monitor.sh
source ./scanner.sh
source ./reporter.sh

show_banner() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}${WHITE}${BOLD}              CLIPBOARD SECURITY SUITE - UNIVERSAL EDITION                      ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}${WHITE}              Real-time Clipboard Protection & Crypto Address Scanner               ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}Developed by:${NC} Hexa Dev                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}Platforms:${NC} Termux | Linux | WSL | macOS                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ${GREEN}Features:${NC} Crypto Detection | Real-time Monitor | Malware Protection  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_menu() {
    while true; do
        show_banner
        
        echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${BLUE}│${NC}  ${WHITE}[1]${NC} Real-time Monitoring Mode                                    ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${WHITE}[2]${NC} Fast Scan (Current Clipboard)                               ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${WHITE}[3]${NC} View Statistics                                             ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${WHITE}[4]${NC} Generate Report                                              ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${WHITE}[5]${NC} Clear History                                                ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${WHITE}[6]${NC} Test with Sample Data                                        ${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  ${WHITE}[7]${NC} Exit                                                        ${BLUE}│${NC}"
        echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
        echo -ne "${CYAN}[INPUT]${NC} Select option: "
        read -r choice
        
        case $choice in
            1) start_monitoring ;;
            2) fast_scan; wait_enter ;;
            3) show_statistics; wait_enter ;;
            4) generate_report; wait_enter ;;
            5) clear_history; wait_enter ;;
            6) run_sample_test; wait_enter ;;
            7) echo -e "${GREEN}[INFO]${NC} Exiting..."; exit 0 ;;
            *) echo -e "${RED}[ERROR]${NC} Invalid option"; sleep 1 ;;
        esac
    done
}

wait_enter() {
    echo ""
    echo -ne "${CYAN}[INPUT]${NC} Press Enter to continue..."
    read -r
}

run_sample_test() {
    local platform=$(get_platform)
    
    echo ""
    echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                   ${WHITE}SAMPLE DATA TEST${NC}                                              ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    echo -e "${YELLOW}[TEST 1]${NC} Setting Bitcoin address to clipboard..."
    set_clipboard "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
    sleep 1
    fast_scan
    
    echo ""
    echo -e "${YELLOW}[TEST 2]${NC} Setting Ethereum address to clipboard..."
    set_clipboard "0x742d35Cc6634C0532925a3b844Bc454e4438f44e"
    sleep 1
    fast_scan
    
    echo ""
    echo -e "${YELLOW}[TEST 3]${NC} Setting normal text to clipboard..."
    set_clipboard "Hello this is normal text for testing"
    sleep 1
    fast_scan
    
    echo ""
    echo -e "${GREEN}[INFO]${NC} Sample test completed"
}

main() {
    init_system
    load_config
    
    case ${1:-} in
        -m|--monitor) start_monitoring ;;
        -f|--fast) fast_scan ;;
        -s|--stats) show_statistics ;;
        -r|--report) generate_report ;;
        -c|--clear) clear_history ;;
        --test) run_sample_test ;;
        -h|--help) show_help ;;
        *) show_menu ;;
    esac
}

main "$@"
