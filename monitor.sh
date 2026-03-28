#!/usr/bin/env bash

start_monitoring() {
    local last_content=""
    local last_hash=""
    
    echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                    ${WHITE}MONITORING MODE ACTIVE${NC}                                    ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}              Press ${RED}Ctrl+C${NC} to stop monitoring                               ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    last_content=$(get_clipboard)
    last_hash=$(calculate_hash "$last_content")
    echo -e "${GREEN}[INFO]${NC} Monitoring started on $(get_platform)"
    echo -e "${GREEN}[INFO]${NC} Current clipboard: ${last_content:-empty}"
    echo ""
    
    while true; do
        local current=$(get_clipboard)
        local current_hash=$(calculate_hash "$current")
        
        if [ -n "$current" ] && [ "$current_hash" != "$last_hash" ]; then
            local source=$(get_source)
            local preview=$(echo "$current" | head -c 100)
            local risk_data=$(calculate_risk "$current")
            local risk_score=$(echo "$risk_data" | cut -d'|' -f1)
            local risk_factors=$(echo "$risk_data" | cut -d'|' -f2)
            
            echo ""
            echo -e "${CYAN}[DETECT]${NC} $(date '+%H:%M:%S') - Clipboard changed"
            echo -e "${GREEN}         Source: ${source:-unknown}${NC}"
            echo -e "${GREEN}         Preview: ${preview}...${NC}"
            echo -e "${GREEN}         Risk Score: ${risk_score}%${NC}"
            
            if [ -n "$risk_factors" ]; then
                echo -e "${GREEN}         Type: ${risk_factors}${NC}"
            fi
            
            if [ $risk_score -ge $HIGH_RISK ]; then
                echo -e "${RED}[ALERT]${NC} HIGH RISK CONTENT DETECTED!"
                echo -e "${RED}[ACTION]${NC} DO NOT PASTE! Verify before using."
                send_notification "Clipboard Alert" "High risk content detected: ${risk_factors}"
                
                if command -v sqlite3 >/dev/null 2>&1; then
                    sqlite3 "$ALERTS_DB" "INSERT INTO alerts (timestamp, alert_type, content_preview, risk_score) VALUES (strftime('%s','now'), 'HIGH_RISK', '$preview', $risk_score);" 2>/dev/null
                fi
            elif [ $risk_score -ge $MEDIUM_RISK ]; then
                echo -e "${YELLOW}[WARN]${NC} Medium risk detected. Verify before pasting."
            fi
            
            echo ""
            last_content="$current"
            last_hash="$current_hash"
            
            if command -v sqlite3 >/dev/null 2>&1; then
                sqlite3 "$HISTORY_DB" "INSERT INTO history (timestamp, content_hash, content_preview, source_app, risk_score, crypto_type) VALUES (strftime('%s','now'), '$current_hash', '$preview', '$source', $risk_score, '$risk_factors');" 2>/dev/null
                sqlite3 "$STATS_DB" "INSERT OR REPLACE INTO stats (date, total_events) VALUES (date('now'), COALESCE((SELECT total_events FROM stats WHERE date=date('now')), 0) + 1);" 2>/dev/null
                
                if [ $risk_score -ge $HIGH_RISK ]; then
                    sqlite3 "$STATS_DB" "UPDATE stats SET total_alerts = COALESCE(total_alerts, 0) + 1, crypto_detections = COALESCE(crypto_detections, 0) + 1 WHERE date = date('now');" 2>/dev/null
                fi
            fi
        fi
        
        sleep "$MONITOR_INTERVAL"
    done
}
