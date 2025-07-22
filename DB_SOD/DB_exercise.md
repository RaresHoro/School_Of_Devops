## 🚀 Quickstart: Azure SQL Server + Database + Firewall + VS Code

```bash
# 1. Create an Azure SQL Logical Server
az sql server create \
  --name sqlserverYOURNAME123 \
  --resource-group sql-exercise-rg \
  --location northeurope \
  --admin-user sqladmin \
  --admin-password MyS3curePassword!123

# 2. Create a SQL Database (Basic Tier)
az sql db create \
  --resource-group sql-exercise-rg \
  --server sqlserverYOURNAME123 \
  --name sampledb \
  --service-objective Basic

# 3. Allow Your IP Through the Firewall
MY_IP=$(curl -s https://ifconfig.me)
az sql server firewall-rule create \
  --resource-group sql-exercise-rg \
  --server sqlserverYOURNAME123 \
  --name AllowMyLaptop \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP

---

# Optional: In VS Code, install the SQL Server (mssql) extension.

Click “Connect” in a .sql file

Server: sqlserverYOURNAME123.database.windows.net

DB: sampledb

User: sqladmin

Password: Thepassword

---
