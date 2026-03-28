#!/usr/bin/env bash

fast_scan() {
    echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                   ${WHITE}FAST SCAN MODE${NC}                                               ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    local content=$(get_clipboard)
    
    if [ -z "$content" ]; then
        echo -e "${YELLOW}[INFO]${NC} Clipboard is empty"
        return
    fi
    
    local source=$(get_source)
    local risk_data=$(calculate_risk "$content")
    local risk_score=$(echo "$risk_data" | cut -d'|' -f1)
    local risk_factors=$(echo "$risk_data" | cut -d'|' -f2)
    
    echo -e "${CYAN}[RESULT]${NC} Clipboard Analysis"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Platform: $(get_platform)${NC}"
    echo -e "${GREEN}  Source: ${source:-unknown}${NC}"
    echo -e "${GREEN}  Content: ${content:0:200}${NC}"
    echo ""
    
    if [ -n "$risk_factors" ]; then
        echo -e "${YELLOW}  Detected: ${risk_factors}${NC}"
    fi
    
    echo -e "${GREEN}  Risk Score: ${risk_score}%${NC}"
    echo ""
    
    if [ $risk_score -ge $HIGH_RISK ]; then
        echo -e "${RED}[CRITICAL]${NC} HIGH RISK CONTENT DETECTED!"
        echo -e "${RED}[ACTION]${NC} DO NOT PASTE! This may be malicious."
        
        if [[ "$risk_factors" == *"crypto"* ]]; then
            echo -e "${RED}[ACTION]${NC} This appears to be a crypto address. Always verify before sending funds."
        fi
    elif [ $risk_score -ge $MEDIUM_RISK ]; then
        echo -e "${YELLOW}[WARN]${NC} Medium risk detected. Verify content before pasting."
    else
        echo -e "${GREEN}[SAFE]${NC} No suspicious patterns detected."
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if command -v sqlite3 >/dev/null 2>&1; then
        local preview=$(echo "$content" | head -c 100)
        local hash=$(calculate_hash "$content")
        sqlite3 "$HISTORY_DB" "INSERT INTO history (timestamp, content_hash, content_preview, source_app, risk_score, crypto_type) VALUES (strftime('%s','now'), '$hash', '$preview', '$source', $risk_score, '$risk_factors');" 2>/dev/null
        sqlite3 "$STATS_DB" "INSERT OR REPLACE INTO stats (date, total_events) VALUES (date('now'), COALESCE((SELECT total_events FROM stats WHERE date=date('now')), 0) + 1);" 2>/dev/null
    fi
}
