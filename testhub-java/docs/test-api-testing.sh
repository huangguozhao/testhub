#!/bin/bash
# API Testing Module Comprehensive Test Script

BASE_URL="http://127.0.0.1:8080/api"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "API Testing Module Comprehensive Test"
echo "========================================="

# Step 1: Login and get token
echo -e "\n${YELLOW}[1/8] Login to get access token...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo -e "${RED}Login failed! Response: $LOGIN_RESPONSE${NC}"
  # Try with testapi002
  echo -e "${YELLOW}Trying with testapi002/test123456...${NC}"
  LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"testapi002","password":"test123456"}')
  TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
  echo -e "${RED}All login attempts failed!${NC}"
  exit 1
fi
echo -e "${GREEN}Login successful! Token: ${TOKEN:0:20}...${NC}"

# Step 2: Get Projects
echo -e "\n${YELLOW}[2/8] Testing GET /api-projects...${NC}"
PROJECTS_RESPONSE=$(curl -s -X GET "$BASE_URL/api-projects" \
  -H "Authorization: Bearer $TOKEN")
echo "Response: $PROJECTS_RESPONSE" | head -c 500
echo "..."

PROJECT_ID=$(echo $PROJECTS_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -n "$PROJECT_ID" ]; then
  echo -e "${GREEN}Found project ID: $PROJECT_ID${NC}"
else
  echo -e "${YELLOW}No projects found${NC}"
  PROJECT_ID=1
fi

# Step 3: Get Collections
echo -e "\n${YELLOW}[3/8] Testing GET /api-collections?projectId=$PROJECT_ID...${NC}"
COLLECTIONS_RESPONSE=$(curl -s -X GET "$BASE_URL/api-collections?projectId=$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN")
echo "Response: $COLLECTIONS_RESPONSE" | head -c 500
echo "..."

COLLECTION_ID=$(echo $COLLECTIONS_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -n "$COLLECTION_ID" ]; then
  echo -e "${GREEN}Found collection ID: $COLLECTION_ID${NC}"
else
  echo -e "${YELLOW}No collections found, creating one...${NC}"
  CREATE_COLLECTION_RESPONSE=$(curl -s -X POST "$BASE_URL/api-collections" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"Test Collection\",\"projectId\":$PROJECT_ID}")
  COLLECTION_ID=$(echo $CREATE_COLLECTION_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
fi

# Step 4: Create a new Request
echo -e "\n${YELLOW}[4/8] Testing POST /api-requests (Create Request)...${NC}"
CREATE_REQUEST_RESPONSE=$(curl -s -X POST "$BASE_URL/api-requests" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"collectionId\": $COLLECTION_ID,
    \"name\": \"Test POST Request\",
    \"method\": \"POST\",
    \"url\": \"https://httpbin.org/post\",
    \"bodyType\": \"json\",
    \"bodyContent\": \"{\\\"test\\\": \\\"data\\\"}\",
    \"headers\": \"[{\\\"key\\\": \\\"Content-Type\\\", \\\"value\\\": \\\"application/json\\\"}]\"
  }")
echo "Response: $CREATE_REQUEST_RESPONSE" | head -c 500
echo "..."

REQUEST_ID=$(echo $CREATE_REQUEST_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ -n "$REQUEST_ID" ]; then
  echo -e "${GREEN}Created request ID: $REQUEST_ID${NC}"
else
  echo -e "${RED}Failed to create request${NC}"
  REQUEST_ID=1
fi

# Step 5: Execute Request
echo -e "\n${YELLOW}[5/8] Testing POST /api-requests/$REQUEST_ID/execute...${NC}"
EXECUTE_RESPONSE=$(curl -s -X POST "$BASE_URL/api-requests/$REQUEST_ID/execute" \
  -H "Authorization: Bearer $TOKEN")
echo "Response: $EXECUTE_RESPONSE" | head -c 500
echo "..."

# Step 6: Update Request
echo -e "\n${YELLOW}[6/8] Testing PUT /api-requests/$REQUEST_ID (Update Request)...${NC}"
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api-requests/$REQUEST_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"collectionId\": $COLLECTION_ID,
    \"name\": \"Updated Test Request\",
    \"method\": \"PUT\",
    \"url\": \"https://httpbin.org/put\",
    \"bodyType\": \"json\",
    \"bodyContent\": \"{\\\"updated\\\": \\\"data\\\"}\"
  }")
echo "Response: $UPDATE_RESPONSE" | head -c 500
echo "..."

# Step 7: Get Request Details
echo -e "\n${YELLOW}[7/8] Testing GET /api-requests/$REQUEST_ID...${NC}"
GET_REQUEST_RESPONSE=$(curl -s -X GET "$BASE_URL/api-requests/$REQUEST_ID" \
  -H "Authorization: Bearer $TOKEN")
echo "Response: $GET_REQUEST_RESPONSE" | head -c 500
echo "..."

# Step 8: Delete Request
echo -e "\n${YELLOW}[8/8] Testing DELETE /api-requests/$REQUEST_ID...${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api-requests/$REQUEST_ID" \
  -H "Authorization: Bearer $TOKEN")
echo "Response: $DELETE_RESPONSE"
echo -e "${GREEN}Delete completed!${NC}"

echo -e "\n========================================="
echo -e "${GREEN}All API tests completed!${NC}"
echo "========================================="
