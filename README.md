## 🚀 Running the Dev Server (Ladybug Environment)

### **1. First-Time Setup (Initialization)**
Before the first run, or after a major core update, prepare the data, database, and binaries:

1. Run VSCode Task `[Status] Check All Services` to view environment state, then:
* **Download Assets:** Run VSCode Task `[Util] Download Client Data`.
* **Import Database:** Run VSCode Task `[Util] Import DB`. *(This executes `ac-db-import` to build and populate the `acore_auth`, `acore_characters`, and `acore_world` schemas).*
* **Compile Core:** Run VSCode Task `[Build] Compile Core`. 
    * *Note: This uses 4 threads of the i7-6700 and utilizes the 16GB swap file for the C++ linking phase. ~10-15 minutes*

---

### **2. Daily Development Workflow (The Loop)**
Once initialized, use this sequence to bring the "Wormhole" online:

1.  **Wake the DB:** Run VSCode Task `[DB] Wake Database`.
    *If this is a fresh setup, start it with `docker compose up -d ac-database`*
2.  **Start Auth:** Run VSCode Task `[Run] Authserver (Native)`. 
    * *Sets IP in `/azerothcore/data/sql/custom/db_auth/tailscale_ip_override.sql`*
3.  **Start World:**
    * Use VSCode **F5** (Launch) configuration `"Linux/Docker debug"` to attach the debugger for C++ logic.
    <!-- * **Standard:** Run VSCode Task `[Run] Worldserver (No Debugger)`. -->
4.  **Verify:** Run VSCode Task `[Status] Check All Services` to ensure volume mapping, database integrity, and service health.

---

### **3. Spin Down (Proper Termination)**
Always shut down in this order to prevent database corruption:

1.  **World:** Type `.server shutdown 5` in the Worldserver console (or stop the VSCode debug session).
2.  **Auth:** Focus the Authserver terminal tab and press `Ctrl+C`.
3.  **Database:** Run VSCode Task `[DB] Hibernate Database`. 
    * *Use `[DB] Hard Reset` only if the Docker network hangs or you need a total tear-down.*