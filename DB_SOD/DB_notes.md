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

# 🧱 SQL Essentials: From Basics to Advanced Queries

This guide outlines essential SQL operations, from table creation to complex queries, including real-world use cases and practical examples.

---

## 📋 Creating Tables

Define the structure of a table using `CREATE TABLE`.

```sql
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    salary NUMERIC(10, 2),
    FOREIGN KEY (department_id) REFERENCES departments(id)
);
```

---

## 📝 Inserting Data

Insert new records into tables using `INSERT INTO`.

```sql
INSERT INTO departments (name) VALUES ('Engineering'), ('HR');

INSERT INTO employees (name, department_id, salary)
VALUES ('Alice', 1, 65000.00),
       ('Bob', 2, 55000.00);
```

---

## 🔐 Constraints

Constraints enforce rules for data integrity.

- `PRIMARY KEY`: Ensures each row is uniquely identifiable.
- `FOREIGN KEY`: Maintains referential integrity between tables.
- `NOT NULL`: Prevents null values in a column.
- `UNIQUE`: Ensures all values in a column are different.
- `CHECK`: Restricts values based on a condition.
- `DEFAULT`: Sets a default value when none is provided.

```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    price NUMERIC CHECK (price > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## ✏️ Update & Delete

Update existing rows:

```sql
UPDATE employees
SET salary = salary * 1.10
WHERE department_id = 1;
```

Delete rows from a table:

```sql
DELETE FROM employees
WHERE name = 'Bob';
```

---

## 🔎 Basic Queries

Select data from a table:

```sql
SELECT * FROM employees;

SELECT name, salary FROM employees
WHERE salary > 60000
ORDER BY salary DESC;
```

---

## 🧮 Functions

Use SQL functions to aggregate and calculate values.

```sql
SELECT COUNT(*) FROM employees;

SELECT AVG(salary) FROM employees;

SELECT MAX(salary), MIN(salary) FROM employees;
```

---

## 🎴 Wildcards

Use `LIKE` for pattern matching in string searches.

```sql
SELECT * FROM employees
WHERE name LIKE 'A%';  -- Names starting with A

SELECT * FROM employees
WHERE name LIKE '_o%'; -- Second letter is "o"
```

---

## 🧩 UNION

Combine the results of two or more `SELECT` statements.

```sql
SELECT name FROM employees
UNION
SELECT name FROM contractors;
```

- `UNION` removes duplicates.
- Use `UNION ALL` to include duplicates.

---

## 🔗 Joins

Joins combine rows from two or more tables based on related columns. They are essential for working with normalized relational data.

### 👇 Table Setup for Examples:

```sql
-- Table: departments
-- id | name
-- 1  | Engineering
-- 2  | HR

-- Table: employees
-- id | name   | department_id
-- 1  | Alice  | 1
-- 2  | Bob    | 2
-- 3  | Carol  | NULL
```

### 1. INNER JOIN

Returns rows when there's a match in both tables.

```sql
SELECT e.name, d.name AS department
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;
```

✅ **Result:**
- Alice | Engineering
- Bob   | HR

Carol is excluded because her `department_id` is NULL (no match).

---

### 2. LEFT JOIN (or LEFT OUTER JOIN)

Returns all rows from the left table, and matched rows from the right table. If there's no match, NULLs are shown for the right table.

```sql
SELECT e.name, d.name AS department
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;
```

✅ **Result:**
- Alice | Engineering
- Bob   | HR
- Carol | NULL

---

### 3. RIGHT JOIN (or RIGHT OUTER JOIN)

Returns all rows from the right table, and matched rows from the left table.

```sql
SELECT e.name, d.name AS department
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.id;
```

✅ Useful when you want to include all departments, even those with no employees.

---

### 4. FULL OUTER JOIN

Returns all records when there is a match in either table. Missing values are filled with NULLs.

```sql
SELECT e.name, d.name AS department
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.id;
```

✅ Includes:
- Employees without departments (e.g. Carol)
- Departments without employees

---

### 5. CROSS JOIN

Returns the Cartesian product — every combination of rows from both tables.

```sql
SELECT e.name, d.name AS department
FROM employees e
CROSS JOIN departments d;
```

✅ Use with caution, as it can return a large number of rows.

---

## 🪜 Nested Queries (Subqueries)

A subquery is a query nested inside another.

```sql
SELECT name FROM employees
WHERE salary > (
    SELECT AVG(salary) FROM employees
);
```

✅ Useful for filtering based on calculated values.

---

## 🧹 ON DELETE

Specify behavior when a referenced row is deleted.

```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    employee_id INT,
    description TEXT,
    FOREIGN KEY (employee_id)
        REFERENCES employees(id)
        ON DELETE SET NULL
);
```

### Other options:
- `CASCADE`: Deletes dependent rows
- `RESTRICT`: Prevents deletion if referenced
- `SET NULL`: Sets referencing column to NULL

---

## 🧠 Triggers

Triggers execute custom logic automatically when a specified event occurs (INSERT, UPDATE, DELETE).

```sql
CREATE FUNCTION log_salary_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO salary_changes (employee_id, old_salary, new_salary, changed_at)
    VALUES (OLD.id, OLD.salary, NEW.salary, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER salary_update_trigger
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION log_salary_change();
```

✅ Useful for auditing, validations, or automated updates.

---
# ☁️ Cloud-Based Database Services
---

## 🌩️ What Are Managed Cloud Databases?

Cloud providers offer **Database-as-a-Service (DBaaS)** platforms. These allow you to:

- **Provision** and configure databases with a few clicks or API calls
- Avoid managing servers, patching, backups, and failovers
- Focus on your application logic instead of infrastructure

---

## 🚀 AWS RDS (Relational Database Service)

**Amazon RDS** is a managed database service for relational databases.

### ✅ Key Features

- Supports popular engines: **PostgreSQL**, **MySQL**, **MariaDB**, **Oracle**, and **SQL Server**
- Automated **backups**, **patch management**, and **monitoring**
- **Multi-AZ deployments** for high availability
- **Read replicas** for scaling reads
- Encryption at rest and in transit

### ⚙️ Example Use Case

**Deploying a MySQL database for a web application:**

```bash
# Using AWS CLI (simplified example)
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --allocated-storage 20 \
  --master-username admin \
  --master-user-password mypass \
  --backup-retention-period 7
```

### 📌 When to Use

- You need a reliable **PostgreSQL/MySQL database** with automatic failover
- You want **enterprise features** without managing database VMs
- Suitable for e-commerce, SaaS, CMS platforms

---

## 🔷 Azure SQL Database

A fully managed, intelligent, and scalable relational database service by Microsoft.

### ✅ Key Features

- Based on the **SQL Server engine**
- **Serverless tier**: Autoscaling compute based on demand
- **Elastic pools**: Share resources across multiple databases
- **Built-in AI-based performance tuning**
- **Geo-replication** for global applications
- Native integration with **Azure Monitor**, **Active Directory**, **Key Vault**

### ⚙️ Example Use Case

**Creating a database from Azure Portal:**

- Navigate to **Azure SQL**
- Click **"Create SQL Database"**
- Choose resource group, set DB name, pricing tier, authentication
- Click **Review + Create**

**Sample connection string:**
```plaintext
Server=tcp:myserver.database.windows.net,1433;
Initial Catalog=mydb;
User ID=admin;Password=mypassword;
```

### 📌 When to Use

- Building apps in the **Microsoft Azure ecosystem**
- Replacing traditional SQL Server deployments
- Applications needing **auto-tuning**, **threat detection**, and **geo-distribution**

---

## 🟡 Google Cloud Spanner

A **globally distributed**, **horizontally scalable** **relational** database designed for cloud-native apps.

### ✅ Key Features

- Combines **relational consistency** (SQL + schemas) with **horizontal NoSQL-like scalability**
- **Global replication** and **multi-region availability**
- **Strong consistency** across data centers
- SQL support with **Spanner Query Language**

### ⚙️ Example Use Case

**Creating an instance:**

- Go to **Google Cloud Console → Spanner**
- Create an instance with desired region and compute/storage allocation
- Create a database and tables using the UI or SQL

```sql
CREATE TABLE Users (
  UserId STRING(36) NOT NULL,
  Name STRING(100),
  Email STRING(MAX)
) PRIMARY KEY (UserId);
```

**Client libraries are available in** Python, Java, Node.js, Go, etc.

### 📌 When to Use

- Apps requiring **horizontal scale + global availability**
- Gaming, FinTech, AdTech systems with global users
- Real-time analytics on live, transactional data

---

## ✅ Summary Comparison

| Feature                | AWS RDS                    | Azure SQL Database             | Google Cloud Spanner               |
|------------------------|----------------------------|-------------------------------|-------------------------------------|
| Database Engines       | MySQL, PostgreSQL, etc.    | SQL Server                    | Cloud-native SQL                   |
| Scalability            | Vertical (some read replicas) | Elastic pools, serverless  | Horizontal + global                |
| High Availability      | Multi-AZ, automatic failover | Geo-replication              | Multi-region, global consistency   |
| Use Cases              | SaaS, e-commerce, internal apps | Web apps, BI dashboards  | Global apps, fintech, IoT          |
| Auto Patching & Backup | Yes                        | Yes                           | Yes                                 |
| Ideal For              | General-purpose RDBMS       | Microsoft ecosystem           | Distributed SQL + NoSQL hybrid     |

---
