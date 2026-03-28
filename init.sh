#!/usr/bin/env bash

init_system() {
    BASE_DIR="$HOME/.clipmon"
    DB_DIR="$BASE_DIR/database"
    LOG_DIR="$BASE_DIR/logs"
    REPORTS_DIR="$BASE_DIR/reports"
    CONFIG_DIR="$BASE_DIR/config"
    
    mkdir -p "$DB_DIR" "$LOG_DIR" "$REPORTS_DIR" "$CONFIG_DIR" 2>/dev/null
    
    HISTORY_DB="$DB_DIR/history.db"
    ALERTS_DB="$DB_DIR/alerts.db"
    STATS_DB="$DB_DIR/stats.db"
    CONFIG_FILE="$CONFIG_DIR/settings.conf"
    
    export BASE_DIR DB_DIR LOG_DIR REPORTS_DIR CONFIG_DIR
    export HISTORY_DB ALERTS_DB STATS_DB CONFIG_FILE
    
    if command -v sqlite3 >/dev/null 2>&1; then
        init_database
    else
        echo -e "${YELLOW}[WARN]${NC} sqlite3 not found. Using file storage."
        touch "$HISTORY_DB" "$ALERTS_DB" "$STATS_DB"
    fi
    
    echo -e "${GREEN}[INIT]${NC} System ready on $(get_platform)"
}

init_database() {
    sqlite3 "$HISTORY_DB" << 'EOF' 2>/dev/null
CREATE TABLE IF NOT EXISTS history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER NOT NULL,
    content_hash TEXT,
    content_preview TEXT,
    source_app TEXT,
    risk_score INTEGER,
    crypto_type TEXT
);
CREATE INDEX IF NOT EXISTS idx_ts ON history(timestamp);
EOF

    sqlite3 "$ALERTS_DB" << 'EOF' 2>/dev/null
CREATE TABLE IF NOT EXISTS alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER NOT NULL,
    alert_type TEXT,
    content_preview TEXT,
    risk_score INTEGER,
    resolved INTEGER DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_alerts_ts ON alerts(timestamp);
EOF

    sqlite3 "$STATS_DB" << 'EOF' 2>/dev/null
CREATE TABLE IF NOT EXISTS stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT UNIQUE,
    total_events INTEGER DEFAULT 0,
    total_alerts INTEGER DEFAULT 0,
    crypto_detections INTEGER DEFAULT 0
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_stats_date ON stats(date);
EOF
}
