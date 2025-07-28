````markdown
# 📘 Azure Storage + SQL Setup Guide (via Azure CLI)

This guide walks you through the process of:

1. Creating a Storage Account
2. Uploading a file from your computer
3. Creating a SQL Server and Database
4. Adding an IP firewall rule to the SQL Server
5. Upgrading the SQL Database to Standard S0 (10 DTUs, 5 GB)

---

## 🧱 1. Create a Resource Group

First, choose a location and create a resource group.

```bash
RESOURCE_GROUP="rg-demo"
LOCATION="northeurope"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
````

---

## 📦 2. Create a Storage Account

The name must be globally unique and use lowercase letters/numbers only.

```bash
STORAGE_ACCOUNT="uniquestorage$RANDOM"

az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot
```

---

## ☁️ 3. Upload a File to Blob Storage

Create a container and upload a file (e.g., `myfile.txt` in your current directory):

```bash
CONTAINER="uploads"

az storage container create \
  --name $CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login

az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER \
  --name myfile.txt \
  --file ./myfile.txt \
  --auth-mode login
```

> ✅ You can also confirm the upload using [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/).

---

## 🗄️ 4. Create a SQL Server and Database

Create a SQL logical server and a basic-tier database.

```bash
SQL_SERVER_NAME="sqlserverdemo$RANDOM"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="MyS3curePassword123"
SQL_DB_NAME="demo-db"

az sql server create \
  --name $SQL_SERVER_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --admin-user $SQL_ADMIN \
  --admin-password $SQL_PASSWORD

az sql db create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name $SQL_DB_NAME \
  --edition Basic \
  --max-size 2GB
```

---

## 🔐 5. Add an IP Restriction to the SQL Server

Allow access to the SQL Server only from your public IP:

```bash
MY_IP=$(curl -s ifconfig.me)

az sql server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name AllowMyIP \
  --start-ip-address $MY_IP \
  --end-ip-address $MY_IP
```

> This is required for external tools like Azure Data Studio or `sqlcmd` to connect to the server.

---

## ⚙️ 6. Upgrade the SQL Database to Standard Tier (S0 - 10 DTUs, 5 GB)

To switch from Basic to Standard S0:

```bash
az sql db update \
  --resource-group $RESOURCE_GROUP \
  --server $SQL_SERVER_NAME \
  --name $SQL_DB_NAME \
  --edition Standard \
  --requested-service-objective-name S0 \
  --max-size 5GB
```

> ✅ This gives the DB more resources, useful for small apps or development workloads.

---

## ✅ Summary

| Task            | Result                                       |
| --------------- | -------------------------------------------- |
| Storage Account | Public, Standard\_LRS, hot-tier blob storage |
| File Upload     | Blob uploaded to `uploads` container         |
| SQL Server + DB | Created with firewall protection             |
| Firewall        | Allows access only from your IP              |
| DB Upgrade      | Now Standard S0 (10 DTUs, 5 GB)              |

---

## 🧹 Optional Cleanup

To delete all created resources:

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

> ⚠️ This will delete the storage account, SQL server, database, and everything inside the resource group.

---

## 🧠 Notes

* You can connect to the SQL Server using Azure Data Studio or `sqlcmd` with:

  ```
  sqlcmd -S <SQL_SERVER_NAME>.database.windows.net -U sqladmin -P MyS3curePassword123 -d demo-db
  ```
* Make sure your IP is added to the firewall rule before attempting external access.

---

```
```


