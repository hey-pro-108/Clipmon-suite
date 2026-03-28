#!/usr/bin/env bash

start_monitoring() {
    local last_content=""
    local last_hash=""
    
    echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                    ${WHITE}MONITORING MODE ACTIVE${NC}                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}              Press ${RED}Ctrl+C${NC} to stop monitoring                               ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    last_content=$(termux-clipboard-get 2>/dev/null)
    echo -e "${GREEN}[INFO]${NC} Monitoring started"
    echo -e "${GREEN}[INFO]${NC} Current: ${last_content:-empty}"
    echo ""
    
    while true; do
        local current=$(termux-clipboard-get 2>/dev/null)
        
        if [ -n "$current" ] && [ "$current" != "$last_content" ]; then
            echo ""
            echo -e "${CYAN}[DETECT]${NC} $(date '+%H:%M:%S') - Clipboard changed"
            echo -e "${GREEN}         Content: ${current:0:100}${NC}"
            
            if [[ "$current" =~ ^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$ ]]; then
                echo -e "${RED}[ALERT]${NC} BITCOIN ADDRESS DETECTED!"
            elif [[ "$current" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
                echo -e "${RED}[ALERT]${NC} ETHEREUM ADDRESS DETECTED!"
            elif [[ "$current" =~ ^bc1[a-zA-HJ-NP-Z0-9]{39,59}$ ]]; then
                echo -e "${RED}[ALERT]${NC} BITCOIN SEGWIT ADDRESS DETECTED!"
            fi
            
            echo ""
            last_content="$current"
        fi
        
        sleep 1
    done
}
