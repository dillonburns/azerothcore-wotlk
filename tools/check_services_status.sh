#!/bin/bash

# ==========================================
# COLOR & TAG DEFINITIONS
# ==========================================
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

OK="[${GREEN}OK${NC}]"
OFFLINE="[${YELLOW}OFFLINE${NC}]"
MISSING="[${RED}MISSING${NC}]"
UNKNOWN="[${YELLOW} ? ${NC}]"


echo -e "${CYAN}=== SETTING ${CYAN}UP ${GREEN}DEV ${CYAN}ENV ===${NC}"
# ==========================================
# 1. PREREQUISITES CHECK
# ==========================================
echo -e "${CYAN}=== PREREQUISITES ===${NC}"

# -- A. Client Data Check --
if [ -f "/azerothcore/env/dist/data/data-version" ]; then
    DATA_VER=$(cat /azerothcore/env/dist/data/data-version)
    echo -e "${OK} Client Data Configured -> ${CYAN}v${DATA_VER}${NC} (/azerothcore/env/dist/data/)"
else
    echo -e "${MISSING} Client Data Missing."
    echo -e "        -> Fix: Run the '[Util] Download Client Data' task."
fi

# -- B. Database Import Check --
DB_ID=$(docker ps -q -f "name=ac-database" -f "status=running")
if [ -n "$DB_ID" ]; then
    # Query information_schema to calculate the size (MB) of the 3 core databases and format as a single line
    QUERY="SELECT GROUP_CONCAT(db_info SEPARATOR '  ') FROM (SELECT CONCAT(table_schema, ' (', ROUND(SUM(data_length + index_length) / 1024 / 1024, 1), 'MB)') AS db_info FROM information_schema.tables WHERE table_schema IN ('acore_auth', 'acore_characters', 'acore_world') GROUP BY table_schema) as subquery;"
    DB_STRING=$(docker compose exec -T ac-database mysql -u root -ppassword -sN -e "$QUERY" 2>/dev/null)
    
    # Verify that all 3 required databases actually exist in the output string
    if [[ "$DB_STRING" == *"acore_auth"* && "$DB_STRING" == *"acore_characters"* && "$DB_STRING" == *"acore_world"* ]]; then
        echo -e "${OK} Databases Imported -> ${CYAN}${DB_STRING}${NC}"
    else
        echo -e "${MISSING} Database Structure Incomplete or Missing."
        echo -e "        -> Found: ${CYAN}${DB_STRING:-None}${NC}"
        echo -e "        -> Fix: Run the '[Util] Import DB' task."
    fi
else
    echo -e "${UNKNOWN} Database Import Status"
    echo -e "        -> DB is offline. Run '[DB] Wake Database' first to verify."
fi

# -- C. Core Build Check --
if [ -x "/azerothcore/env/dist/bin/worldserver" ] && [ -x "/azerothcore/env/dist/bin/authserver" ]; then
    AUTH_SIZE=$(ls -lh /azerothcore/env/dist/bin/authserver | awk '{print $5}')
    WORLD_SIZE=$(ls -lh /azerothcore/env/dist/bin/worldserver | awk '{print $5}')
    echo -e "${OK} Core Built & Executable -> ${CYAN}Auth: ${AUTH_SIZE} | World: ${WORLD_SIZE}${NC}"
else
    echo -e "${MISSING} Core not built or missing executable permissions."
    echo -e "        -> Fix: Run the '[Build] Compile Core (Debug)' task."
fi

# ==========================================
# 2. DOCKER WAREHOUSE STATUS
# ==========================================
echo -e "\n${CYAN}=== DOCKER CONTAINERS ===${NC}"

if [ -n "$DB_ID" ]; then
    # Grab exact uptime and mapped ports
    DB_INFO=$(docker ps -f "id=$DB_ID" --format "{{.Status}} | {{.Ports}}")
    echo -e "${OK} ac-database (MySQL) -> ${CYAN}${DB_INFO}${NC}"
else
    echo -e "${OFFLINE} ac-database (MySQL)"
    echo -e "        -> Fix: Run the '[DB] Wake Database' task."
fi

DEV_ID=$(docker ps -q -f "name=ac-dev-server" -f "status=running")
if [ -n "$DEV_ID" ]; then
    DEV_INFO=$(docker ps -f "id=$DEV_ID" --format "{{.Status}} | Image: {{.Image}}")
    echo -e "${OK} ac-dev-server (VS Code) -> ${CYAN}${DEV_INFO}${NC}"
else
    echo -e "${OFFLINE} ac-dev-server (VS Code)"
fi

# ==========================================
# 3. NATIVE PROCESS STATUS (Auth/World)
# ==========================================
echo -e "\n${CYAN}=== NATIVE PROCESSES ===${NC}"

AUTH_PID=$(pgrep -f "env/dist/bin/authserver" | head -n 1)
if [ -n "$AUTH_PID" ]; then
    # Grab Uptime (etime), CPU usage, and Memory usage
    AUTH_STATS=$(ps -p $AUTH_PID -o etime=,%cpu=,%mem= | xargs)
    echo -e "${OK} authserver -> ${CYAN}PID ${AUTH_PID} | Uptime: ${AUTH_STATS%% *} | CPU/Mem: ${AUTH_STATS#* }${NC}"
else
    echo -e "${OFFLINE} authserver"
    echo -e "        -> Fix: Run the '[Run] Authserver (Native)' task."
fi

WORLD_PID=$(pgrep -f "env/dist/bin/worldserver" | head -n 1)
if [ -n "$WORLD_PID" ]; then
    WORLD_STATS=$(ps -p $WORLD_PID -o etime=,%cpu=,%mem= | xargs)
    echo -e "${OK} worldserver -> ${CYAN}PID ${WORLD_PID} | Uptime: ${WORLD_STATS%% *} | CPU/Mem: ${WORLD_STATS#* }${NC}"
else
    echo -e "${OFFLINE} worldserver"
    echo -e "        -> Fix: Launch Debugger (F5)"
fi

echo -e "\n"