
---

````markdown
# 🐬 MySQL Server Guide: CRUD, Indexing, Backup, Replication & Structure

---

## 📐 Relational Database Structure (MySQL)

MySQL is a **relational database** that stores data in structured **tables**, using **schemas** with **defined columns** and **data types**.

### 🧱 Core Structure

- **Database**
  - **Tables**
    - **Rows** = individual records
    - **Columns** = typed fields (`INT`, `VARCHAR`, `DATE`, etc.)

### 🔍 Example: `books` Table

```sql
CREATE TABLE books (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(100),
  author VARCHAR(100),
  rating DECIMAL(2,1),
  published DATE
);
````

---

## ✏️ CRUD Operations in MySQL

### 🟢 Create

```sql
INSERT INTO books (title, author, rating, published)
VALUES ('1984', 'George Orwell', 4.6, '1949-06-08');
```

### 🔵 Read

```sql
SELECT * FROM books WHERE author = 'George Orwell';
```

### 🟡 Update

```sql
UPDATE books
SET rating = 4.7
WHERE title = '1984';
```

### 🔴 Delete

```sql
DELETE FROM books WHERE title = '1984';
```

---

## 🚀 Indexing & Performance Optimization

Indexes in MySQL help speed up SELECT queries, especially on large tables.

### 📌 Create Index

```sql
CREATE INDEX idx_author ON books(author);
```

### 🧠 Composite Index

```sql
CREATE INDEX idx_author_rating ON books(author, rating);
```

### 🔍 Check Query Plan

```sql
EXPLAIN SELECT * FROM books WHERE author = 'George Orwell';
```

> Look for `Using index` or `Using where` in the output.

### ⚡ Best Practices

* Always index columns used in `WHERE`, `JOIN`, `ORDER BY`
* Avoid indexing columns with low cardinality (e.g., booleans)
* Use **covering indexes** to avoid table lookups

---

## 🛡️ Backup & Recovery Strategies in MySQL

### 📦 Backup Using `mysqldump`

#### Full Database Backup

```bash
mysqldump -u root -p bookstore > bookstore_backup.sql
```

#### Single Table Backup

```bash
mysqldump -u root -p bookstore books > books_backup.sql
```

> This outputs SQL statements you can replay to restore the data.

---

### 🔁 Restore from Backup

```bash
mysql -u root -p bookstore < bookstore_backup.sql
```

---

## 🧩 Replication & High Availability (MySQL)

MySQL supports several types of replication for **read scaling**, **backup**, and **HA**.

### 🔁 Basic Asynchronous Replication

| Role       | Description                 |
| ---------- | --------------------------- |
| **Master** | Accepts writes              |
| **Slave**  | Replicates data from master |

---

### ⚙️ Minimal Replication Setup

1. **On Master**, enable binary logging in `my.cnf`:

```ini
[mysqld]
server-id=1
log-bin=mysql-bin
```

2. **On Slave**, configure:

```ini
[mysqld]
server-id=2
relay-log=relay-log
```

3. Run these on the **Slave**:

```sql
CHANGE MASTER TO
  MASTER_HOST='master_ip',
  MASTER_USER='replica_user',
  MASTER_PASSWORD='replica_pass',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS= 107;

START SLAVE;
```

4. Verify with:

```sql
SHOW SLAVE STATUS\G
```

> Look for `"Slave_IO_Running: Yes"` and `"Slave_SQL_Running: Yes"`

---

### ✅ Tools for HA

| Feature                       | MySQL Technology                |
| ----------------------------- | ------------------------------- |
| Asynchronous Replication      | Built-in `mysqld`               |
| Semi-sync Replication         | Available in MySQL 5.7+ plugins |
| Group Replication             | Built-in for multi-master HA    |
| MySQL Router + InnoDB Cluster | Native HA and load balancing    |

---

## 🧠 Summary

| Feature              | MySQL Tool / Command                                  |
| -------------------- | ----------------------------------------------------- |
| **CRUD**             | `INSERT`, `SELECT`, `UPDATE`, `DELETE`                |
| **Indexing**         | `CREATE INDEX`, `EXPLAIN`                             |
| **Backup & Restore** | `mysqldump`, `mysql`                                  |
| **Replication & HA** | Binary logging, `CHANGE MASTER TO`, Group Replication |
| **Structure**        | Tables, Columns, Rows, Constraints                    |

---

## 🔧 Useful MySQL CLI Tools

| Tool         | Use                               |
| ------------ | --------------------------------- |
| `mysql`      | Connect to MySQL and run SQL      |
| `mysqldump`  | Backup databases to `.sql` files  |
| `mysqladmin` | Manage server (shutdown, status)  |
| `my.cnf`     | Server config (auth, replication) |
| `EXPLAIN`    | Analyze query performance         |

---

## 📘 Final Notes

MySQL is a robust relational database ideal for:

* Structured data with schema enforcement
* Transactions (ACID)
* Apps requiring consistent reads and strong joins

🔁 Replication enables horizontal scaling and HA
💾 Backup with `mysqldump` is simple and scriptable
🚀 Indexing is key to performance in large apps

---

```


