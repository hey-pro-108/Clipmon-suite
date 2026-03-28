#!/usr/bin/env bash

detect_crypto() {
    local content="$1"
    
    if [[ "$content" =~ ^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$ ]]; then
        echo "BITCOIN_LEGACY|50"
    elif [[ "$content" =~ ^bc1[a-zA-HJ-NP-Z0-9]{39,59}$ ]]; then
        echo "BITCOIN_SEGWIT|50"
    elif [[ "$content" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        echo "ETHEREUM|50"
    elif [[ "$content" =~ ^T[A-Za-z1-9]{33}$ ]]; then
        echo "TRON|45"
    elif [[ "$content" =~ ^r[0-9a-zA-Z]{24,34}$ ]]; then
        echo "RIPPLE|45"
    elif [[ "$content" =~ ^[1-9A-HJ-NP-Za-km-z]{32,44}$ ]] && [ ${#content} -ge 32 ]; then
        echo "SOLANA|45"
    elif [[ "$content" =~ ^addr1[0-9a-z]{38,100}$ ]]; then
        echo "CARDANO|45"
    elif [[ "$content" =~ ^[48][0-9AB][1-9A-HJ-NP-Za-km-z]{94,95}$ ]]; then
        echo "MONERO|50"
    else
        echo ""
    fi
}

detect_url() {
    local content="$1"
    local url_pattern='(https?://|www\.)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[a-zA-Z0-9?=&%.-]*)?'
    
    if [[ "$content" =~ $url_pattern ]]; then
        local url=$(echo "$content" | grep -oE "$url_pattern" | head -1)
        echo "$url|20"
    else
        echo ""
    fi
}

detect_apikey() {
    local content="$1"
    
    if [[ "$content" =~ ^sk_live_[a-zA-Z0-9]{24}$ ]]; then
        echo "STRIPE_SECRET|80"
    elif [[ "$content" =~ ^ghp_[a-zA-Z0-9]{36}$ ]]; then
        echo "GITHUB_TOKEN|75"
    elif [[ "$content" =~ ^[a-zA-Z0-9]{32,40}$ ]] && [ ${#content} -eq 32 ]; then
        echo "API_KEY_32|60"
    elif [[ "$content" =~ ^[a-zA-Z0-9_-]{20,40}\.[a-zA-Z0-9_-]{20,40}\.[a-zA-Z0-9_-]{20,40}$ ]]; then
        echo "JWT_TOKEN|70"
    else
        echo ""
    fi
}

calculate_risk() {
    local content="$1"
    local risk=0
    local factors=""
    
    if [ "$ENABLE_CRYPTO" = "true" ]; then
        local crypto_data=$(detect_crypto "$content")
        local crypto_type=$(echo "$crypto_data" | cut -d'|' -f1)
        local crypto_risk=$(echo "$crypto_data" | cut -d'|' -f2)
        
        if [ -n "$crypto_type" ]; then
            risk=$((risk + crypto_risk))
            factors="${factors}crypto_$crypto_type "
        fi
    fi
    
    if [ "$ENABLE_URL" = "true" ]; then
        local url_data=$(detect_url "$content")
        local url_risk=$(echo "$url_data" | cut -d'|' -f2)
        
        if [ -n "$url_risk" ] && [ "$url_risk" -gt 0 ]; then
            risk=$((risk + url_risk))
            factors="${factors}url_detected "
        fi
    fi
    
    local apikey_data=$(detect_apikey "$content")
    local apikey_type=$(echo "$apikey_data" | cut -d'|' -f1)
    local apikey_risk=$(echo "$apikey_data" | cut -d'|' -f2)
    
    if [ -n "$apikey_type" ]; then
        risk=$((risk + apikey_risk))
        factors="${factors}${apikey_type} "
    fi
    
    if [ $risk -gt 100 ]; then
        risk=100
    fi
    
    echo "$risk|$factors"
}
