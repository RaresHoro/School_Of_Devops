# 🗃️ Introduction to Databases

A **database** is a structured collection of data that can be easily accessed, managed, and updated. Databases are foundational to almost every application—from small mobile apps to large-scale enterprise systems.

## 🎯 Purpose of Databases

- Store and organize information
- Enable fast retrieval and queries
- Support data integrity and security
- Allow multiple users and applications to work with data concurrently

---

## 📚 Types of Databases: SQL vs NoSQL

There are two main categories of modern databases:

---

### 1. **SQL Databases** (Relational)

SQL databases use **structured schemas** with predefined tables and relationships. They rely on the **Structured Query Language (SQL)** to manage and query data.

#### ✅ Characteristics

- **Relational model**: Data organized in rows and tables
- **Fixed schema**: Requires structure before inserting data
- **ACID compliance**: Ensures reliability (Atomicity, Consistency, Isolation, Durability)
- **Joins**: Strong support for relational data

#### 📦 Common SQL Databases

##### 🔹 PostgreSQL

- Open-source, powerful, and extensible
- Advanced features like window functions, full-text search, and GIS support
- Strong standards compliance and ACID transactions

##### 🔹 MySQL

- One of the most popular open-source relational databases
- Known for speed and reliability
- Widely used in web development (especially with PHP and WordPress)

#### 📌 Ideal Use Cases

- Applications requiring data integrity and complex queries
- Banking systems, ERP, CMS, and analytics platforms

---

### 2. **NoSQL Databases** (Non-relational)

NoSQL databases offer flexible schemas for unstructured or semi-structured data. They were designed to scale horizontally and handle large volumes of diverse data.

#### ✅ Characteristics

- **Schema-less** or dynamic schema
- Optimized for **read/write speed** and **scalability**
- **BASE model** (Basically Available, Soft state, Eventually consistent)
- Multiple types: document, key-value, columnar, graph

#### 📦 Common NoSQL Databases

##### 🔹 MongoDB (Document Store)

- Stores data as flexible **JSON-like documents**
- Great for hierarchical and nested data
- Schema-on-read makes it ideal for agile development
- Good support for indexing and aggregation

##### 🔹 Redis (Key-Value Store)

- In-memory data store with blazing speed
- Commonly used for **caching**, **session storage**, and **real-time analytics**
- Supports data types like strings, lists, sets, and sorted sets

#### 📌 Ideal Use Cases

- Big data, IoT, content management, and real-time systems
- Apps with changing or evolving data models

---

## ⚖️ SQL vs NoSQL: Feature Comparison

| Feature             | SQL (PostgreSQL, MySQL)     | NoSQL (MongoDB, Redis)             |
|---------------------|------------------------------|------------------------------------|
| Data structure      | Tables (rows and columns)    | Documents, Key-Value, etc.         |
| Schema              | Predefined (rigid)           | Dynamic or schema-less             |
| Scalability         | Vertical                     | Horizontal                         |
| Transactions        | Strong (ACID)                | Varies (often BASE)                |
| Query Language      | SQL                          | Varies (Mongo Query, Redis CLI)    |
| Performance         | Optimized for joins & queries| Optimized for speed & scalability  |
| Ideal Use           | Structured, related data     | Flexible, rapidly changing data    |

---
## ✏️ CRUD Operations

CRUD stands for the four basic operations performed on database records:

| Operation | SQL Example                         | NoSQL (MongoDB) Example             |
|-----------|--------------------------------------|-------------------------------------|
| Create    | `INSERT INTO users (...) VALUES (...)` | `db.users.insertOne({...})`         |
| Read      | `SELECT * FROM users WHERE id = 1`    | `db.users.find({ id: 1 })`          |
| Update    | `UPDATE users SET name='Alice' WHERE id=1` | `db.users.updateOne({id: 1}, {$set: {name: 'Alice'}})` |
| Delete    | `DELETE FROM users WHERE id = 1`      | `db.users.deleteOne({ id: 1 })`     |

These operations form the foundation of all interactions with both relational and non-relational databases.

---

## ⚡ Indexing and Performance Optimization

Indexes improve the speed of data retrieval operations at the cost of additional space and slower writes.

### 🔍 Indexing Strategies

- **Single-field index:** Index on one field (e.g., `email`)
- **Compound index:** Index on multiple fields (e.g., `first_name + last_name`)
- **Unique index:** Enforces uniqueness (e.g., usernames)

### 🛠 Performance Tips

- Use **EXPLAIN** plans to analyze SQL queries
- Avoid `SELECT *` in production queries
- Normalize to reduce redundancy in SQL, denormalize for faster reads in NoSQL
- Use **caching** (e.g., Redis) for frequently accessed data

---

## 💾 Backup and Recovery Strategies

A robust database system includes mechanisms for protecting and restoring data.

### 🧰 Common Backup Types

- **Full backup:** Complete snapshot of the database
- **Incremental backup:** Only changes since the last backup
- **Logical backup:** SQL dumps or BSON (MongoDB)
- **Physical backup:** File-level backup of database files

### 🔄 Recovery Techniques

- Point-in-time recovery (PITR)
- Replication-based recovery
- Restore from dump or snapshot

📝 Tip: Automate backups and routinely test recovery processes!

---

## 🌐 Database Replication and High Availability

### 🔁 Replication

Replication involves copying data from one database server to another.

- **Master-slave:** One write node, multiple read replicas
- **Multi-master:** Multiple write-capable nodes (conflict resolution needed)
- **Replica sets (MongoDB):** Primary and multiple secondaries

### 🟢 High Availability (HA)

High availability ensures minimal downtime by using:

- **Failover systems**
- **Load balancers**
- **Heartbeat mechanisms**
- **Geo-distributed clusters**

⏱️ Goal: Ensure data is available and consistent even in the event of hardware or network failure.

