#!/bin/sh

# costants
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Load environment variables
# Only for local development
# for x in $(cat .env); do
#     export $x
# done

# Check environment variables
check_env() {
    if [ -z "${API_TOKEN}" ]; then
        echo "${RED}The API_TOKEN environment variable is not set${NC}"
        local pass=0
    fi

    if [ -z "${ZONE_IDENTIFIER}" ]; then
        echo "${RED}The ZONE_IDENTIFIER environment variable is not set${NC}"
        local pass=0
    fi

    if [ $pass -eq 0 ]; then
        echo "${RED}Set the environments variables${NC}"
        exit 1
    fi
}

# Get the current machine public IP address
get_public_ip() {
    echo "Getting the public IP address..."
    PUBLIC_IP=$(curl -s "https://ipinfo.io/ip" || curl -s "https://ipv4.icanhazip.com")

    if [ -z "${PUBLIC_IP}" ]; then
        echo "${RED}The public IP address could not be retrieved${NC}"
        exit 1
    fi

    echo "${GREEN}The public IP address is ${PUBLIC_IP}${NC}"
}

# Get the current record
get_current_record() {
    echo "Getting the current record..."
    RECORD=$(curl -s -H "Authorization: Bearer ${API_TOKEN}" "https://api.cloudflare.com/client/v4/zones/${ZONE_IDENTIFIER}/dns_records/?type=A" | jq .result)

    if [ -z "${RECORD}" ]; then
        echo -e "${RED}The record could not be retrieved${NC}"
        exit 1
    fi

    RECORD_IP=$(echo ${RECORD} | jq '.[0].content' | tr -d '"')
    echo "${GREEN}The record IP address is ${RECORD_IP}${NC}"
}

# Check if the current public IP address is the same as the record IP address
check_old_ip() {
    if [ $RECORD_IP = $PUBLIC_IP ]; then
        echo "The public IP address is the same as the record IP address, quitting..."
        exit 0
    fi
}

# Update the record
update_record() {
    echo "The record IP address is different from the public IP address. Updating the record..."
    RECORD_IDS=$(echo ${RECORD} | jq '.[].id' | tr -d '"')
    
    for RECORD_ID in $RECORD_IDS; do
        RESPONSE=$(curl -s -X PATCH -d "{\"content\":\"${PUBLIC_IP}\"}" -H "Authorization: Bearer ${API_TOKEN}" "https://api.cloudflare.com/client/v4/zones/${ZONE_IDENTIFIER}/dns_records/${RECORD_ID}")

        if [ -z "$RESPONSE" ]; then
            echo "${RED}The record ${RECORD_ID} could not be updated${NC}"
        fi

        echo "${GREEN}The records ${RECORD_ID} has been updated with $(echo ${RESPONSE} | jq .result.content)${NC}"
    done
}

check_env
get_public_ip
get_current_record
check_old_ip
update_record