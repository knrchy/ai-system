#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 Upload Sample Data to Data Pipeline"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# Check if file argument provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No file specified${NC}"
    echo ""
    echo "Usage: $0 <json-file> [csv-file]"
    echo ""
    echo "Example:"
    echo "  $0 results.json"
    echo "  $0 results.json transactions.csv"
    exit 1
fi


JSON_FILE=$1
CSV_FILE=$2


# Check if JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo -e "${RED}Error: File not found: $JSON_FILE${NC}"
    exit 1
fi


echo -e "${YELLOW}Uploading backtest data...${NC}"
echo ""
echo "JSON file: $JSON_FILE"
if [ -n "$CSV_FILE" ]; then
    echo "CSV file: $CSV_FILE"
fi
echo ""


# Build curl command
CURL_CMD="curl -X POST http://localhost:30800/api/v1/ingest"
CURL_CMD="$CURL_CMD -F json_file=@$JSON_FILE"


if [ -n "$CSV_FILE" ]; then
    CURL_CMD="$CURL_CMD -F csv_file=@$CSV_FILE"
fi


CURL_CMD="$CURL_CMD -F name=Uploaded_$(date +%Y%m%d_%H%M%S)"
CURL_CMD="$CURL_CMD -F description=Uploaded via script"
CURL_CMD="$CURL_CMD -F initial_balance=10000"


# Execute upload
echo -e "${YELLOW}Uploading...${NC}"
RESPONSE=$(eval $CURL_CMD)


echo ""
echo -e "${GREEN}Response:${NC}"
echo $RESPONSE | jq '.'


# Extract backtest_id
BACKTEST_ID=$(echo $RESPONSE | jq -r '.backtest_id')


if [ "$BACKTEST_ID" != "null" ]; then
    echo ""
    echo -e "${GREEN}✅ Upload successful!${NC}"
    echo ""
    echo "Backtest ID: $BACKTEST_ID"
    echo ""
    echo "View details:"
    echo "  curl http://localhost:30800/api/v1/backtests/$BACKTEST_ID | jq '.'"
else
    echo ""
    echo -e "${RED}❌ Upload failed${NC}"
    exit 1
fi
