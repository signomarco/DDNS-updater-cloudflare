#!/bin/sh

# costants
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Get the current machine public IP address
echo "Getting the public IP address..."
PUBLIC_IP=$(curl -s "https://ipinfo.io/ip" || curl -s "https://ipv4.icanhazip.com")

if [ -z "${PUBLIC_IP}" ]; then
    echo -e "${RED}The public IP address could not be retrieved${NC}"
    exit 1
fi
echo -e "${GREEN}The public IP address is ${PUBLIC_IP}${NC}"

# Get the current record
echo "Getting the current record..."
RECORD=$(curl -s -H "Authorization: Bearer ${API_TOKEN}" "https://api.cloudflare.com/client/v4/zones/${ZONE_IDENTIFIER}/dns_records/?type=A" | jq .result)

if [ -z "${RECORD}" ]; then
    echo -e "${RED}The record could not be retrieved${NC}"
    exit 1
fi
RECORD_IP=$(echo ${RECORD} | jq '.[0].content' | tr -d '"')
echo -e "${GREEN}The record IP address is ${RECORD_IP}${NC}"

# Check if the current public IP address is the same as the record IP address
if [ $RECORD_IP = $PUBLIC_IP ]; then
    echo "The public IP address is the same as the record IP address, quitting..."
    exit 0
fi

# Update the record
echo "The record IP address is different from the public IP address. Updating the record..."
RECORD_ID=$(echo ${RECORD} | jq '.[0].id' | tr -d '"')
RESPONSE=$(curl -s -X PATCH -d "{\"content\":\"${PUBLIC_IP}\"}" -H "Authorization: Bearer ${API_TOKEN}" "https://api.cloudflare.com/client/v4/zones/${ZONE_IDENTIFIER}/dns_records/${RECORD_ID}")

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}The record could not be updated${NC}"
    exit 1
fi

echo -e "${GREEN}The record has been updated with $(echo ${RESPONSE} | jq .result.content)${NC}"