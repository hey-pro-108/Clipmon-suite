#!/usr/bin/env bash

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        create_default_config
    fi
    
    source "$CONFIG_FILE" 2>/dev/null
    
    MONITOR_INTERVAL=${MONITOR_INTERVAL:-1}
    HIGH_RISK=${HIGH_RISK:-70}
    MEDIUM_RISK=${MEDIUM_RISK:-40}
    ENABLE_CRYPTO=${ENABLE_CRYPTO:-true}
    ENABLE_URL=${ENABLE_URL:-true}
    ENABLE_NOTIFY=${ENABLE_NOTIFY:-true}
    
    export MONITOR_INTERVAL HIGH_RISK MEDIUM_RISK
    export ENABLE_CRYPTO ENABLE_URL ENABLE_NOTIFY
}

create_default_config() {
    cat > "$CONFIG_FILE" << 'EOF'
MONITOR_INTERVAL=1
HIGH_RISK=70
MEDIUM_RISK=40
ENABLE_CRYPTO=true
ENABLE_URL=true
ENABLE_NOTIFY=true
EOF
    echo -e "${GREEN}[CONFIG]${NC} Default config created"
}
