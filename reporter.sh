#!/usr/bin/env bash

generate_report() {
    local report_file="$REPORTS_DIR/report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=================================================="
        echo "CLIPBOARD SECURITY SUITE - SECURITY REPORT"
        echo "=================================================="
        echo "Generated: $(date)"
        echo "Platform: $(get_platform)"
        echo ""
        echo "------------------- STATISTICS -------------------"
        
        if command -v sqlite3 >/dev/null 2>&1 && [ -f "$STATS_DB" ]; then
            sqlite3 "$STATS_DB" "SELECT date, total_events, total_alerts, crypto_detections FROM stats ORDER BY date DESC LIMIT 10;" 2>/dev/null | while IFS='|' read -r date events alerts crypto; do
                echo "  $date: $events events, $alerts alerts, $crypto crypto"
            done
        else
            echo "  No statistics available"
        fi
        
        echo ""
        echo "------------------- ALERT HISTORY -------------------"
        
        if command -v sqlite3 >/dev/null 2>&1 && [ -f "$ALERTS_DB" ]; then
            sqlite3 "$ALERTS_DB" "SELECT datetime(timestamp, 'unixepoch', 'localtime'), alert_type, risk_score, content_preview FROM alerts ORDER BY timestamp DESC LIMIT 20;" 2>/dev/null | while IFS='|' read -r ts type risk preview; do
                echo "  [$ts] $type (Risk:$risk%): $preview"
            done
        else
            echo "  No alerts recorded"
        fi
        
        echo ""
        echo "------------------- RECENT ACTIVITY -------------------"
        
        if command -v sqlite3 >/dev/null 2>&1 && [ -f "$HISTORY_DB" ]; then
            sqlite3 "$HISTORY_DB" "SELECT datetime(timestamp, 'unixepoch', 'localtime'), risk_score, crypto_type, source_app, content_preview FROM history ORDER BY timestamp DESC LIMIT 15;" 2>/dev/null | while IFS='|' read -r ts risk type source preview; do
                echo "  [$ts] Risk:$risk% | $type | $source: ${preview:0:50}"
            done
        else
            echo "  No history available"
        fi
        
        echo ""
        echo "------------------- CONFIGURATION -------------------"
        echo "  Monitor Interval: ${MONITOR_INTERVAL}s"
        echo "  High Risk Threshold: ${HIGH_RISK}%"
        echo "  Medium Risk Threshold: ${MEDIUM_RISK}%"
        echo "  Crypto Detection: $ENABLE_CRYPTO"
        echo "  URL Detection: $ENABLE_URL"
        echo "  Notifications: $ENABLE_NOTIFY"
        
        echo ""
        echo "=================================================="
    } > "$report_file"
    
    echo -e "${GREEN}[INFO]${NC} Report saved: $report_file"
}

show_statistics() {
    echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                   ${WHITE}STATISTICS${NC}                                                   ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    local platform=$(get_platform)
    local alert_count=0
    local event_count=0
    local crypto_count=0
    
    if command -v sqlite3 >/dev/null 2>&1 && [ -f "$ALERTS_DB" ]; then
        alert_count=$(sqlite3 "$ALERTS_DB" "SELECT COUNT(*) FROM alerts;" 2>/dev/null)
        event_count=$(sqlite3 "$HISTORY_DB" "SELECT COUNT(*) FROM history;" 2>/dev/null)
        crypto_count=$(sqlite3 "$ALERTS_DB" "SELECT COUNT(*) FROM alerts WHERE alert_type='HIGH_RISK';" 2>/dev/null)
    fi
    
    echo -e "${GREEN}  Platform: $platform${NC}"
    echo -e "${GREEN}  Total Events: $event_count${NC}"
    echo -e "${GREEN}  Total Alerts: $alert_count${NC}"
    echo -e "${GREEN}  Crypto Alerts: $crypto_count${NC}"
    echo -e "${GREEN}  Config: $CONFIG_DIR${NC}"
    echo -e "${GREEN}  Database: $DB_DIR${NC}"
    echo -e "${GREEN}  Logs: $LOG_DIR${NC}"
    echo -e "${GREEN}  Reports: $REPORTS_DIR${NC}"
    echo ""
}

clear_history() {
    if command -v sqlite3 >/dev/null 2>&1; then
        sqlite3 "$HISTORY_DB" "DELETE FROM history;" 2>/dev/null
        sqlite3 "$ALERTS_DB" "DELETE FROM alerts;" 2>/dev/null
        echo -e "${GREEN}[INFO]${NC} History cleared"
    else
        > "$HISTORY_DB" 2>/dev/null
        > "$ALERTS_DB" 2>/dev/null
        echo -e "${GREEN}[INFO]${NC} History cleared"
    fi
}
