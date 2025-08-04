````markdown
# 🗃️ MongoDB Guide: CRUD, Indexing, Backup, Replication & NoSQL Structure

---

## 📐 NoSQL Database Structure (MongoDB)

MongoDB is a **document-oriented NoSQL database**. It stores data in a **JSON-like format** (BSON).

### 🧱 Core Structure:

- **Database** → contains
  - **Collections** → contains
    - **Documents** (like rows in SQL, but flexible)

### 🔍 Example:

```json
{
  "_id": ObjectId("..."),
  "title": "The Hobbit",
  "author": "J.R.R. Tolkien",
  "genres": ["Fantasy", "Adventure"],
  "rating": 4.8,
  "published": ISODate("1937-09-21")
}
````

MongoDB collections are **schema-less**, which means:

* No predefined columns
* Each document can have different fields
* Perfect for flexible, fast-changing data

---

## ✏️ CRUD Operations in MongoDB

### 🟢 Create

```js
db.books.insertOne({
  title: "1984",
  author: "George Orwell",
  rating: 4.6
});
```

### 🔵 Read

```js
db.books.find({ author: "George Orwell" });
```

### 🟡 Update

```js
db.books.updateOne(
  { title: "1984" },
  { $set: { rating: 4.7 } }
);
```

### 🔴 Delete

```js
db.books.deleteOne({ title: "1984" });
```

---

## 🚀 Indexing & Performance Optimization

Indexes make queries faster, especially on large datasets.

### 📌 Create Index

```js
db.books.createIndex({ author: 1 }); // ascending index
```

### 🔍 Check Usage with `explain()`

```js
db.books.find({ author: "J.R.R. Tolkien" }).explain("executionStats");
```

> Look for `"IXSCAN"` (Index Scan) vs `"COLLSCAN"` (Collection Scan)

### ⚡ Tips:

* Use **compound indexes** for queries using multiple fields
* Use **`.explain()`** to measure performance
* Avoid indexing rarely-used fields (adds write overhead)

---

## 🛡️ Backup & Recovery Strategies

### 📦 Backup with `mongodump`

```bash
mongodump --db shop --out ./backup
```

Creates a folder `./backup/shop` with `.bson` and `.json` files.

### 🧬 Restore with `mongorestore`

```bash
mongorestore --db shop ./backup/shop
```

### 🔐 Partial Backup (One Collection)

```bash
mongodump --db shop --collection orders --out ./backup
```

> Backups should be scheduled regularly using cron jobs or scripts.

---

## 🧩 Replication & High Availability

### 🔁 What is a Replica Set?

A **replica set** is a cluster of MongoDB servers:

* One **primary** (writes allowed)
* Multiple **secondaries** (read-only)
* Automatic **failover** if primary goes down

### 🏗️ Setup Locally (Example)

Start 3 nodes on different ports:

```bash
mongod --replSet rs0 --port 27017 --dbpath ./node1/data --bind_ip localhost
mongod --replSet rs0 --port 27018 --dbpath ./node2/data --bind_ip localhost
mongod --replSet rs0 --port 27019 --dbpath ./node3/data --bind_ip localhost
```

Initialize:

```js
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:27017" },
    { _id: 1, host: "localhost:27018" },
    { _id: 2, host: "localhost:27019" }
  ]
});
```

### 🔗 Connect to Replica Set

```js
mongodb://localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0
```

> Applications using this URI will automatically failover and load-balance across secondaries if configured.

---

## 🧠 Summary

| Feature              | Tool / Command                                            |
| -------------------- | --------------------------------------------------------- |
| **CRUD**             | `.insertOne()`, `.find()`, `.updateOne()`, `.deleteOne()` |
| **Indexing**         | `createIndex()`, `explain()`                              |
| **Backup & Restore** | `mongodump`, `mongorestore`                               |
| **Replication & HA** | `rs.initiate()`, `rs.status()`                            |
| **NoSQL Structure**  | Documents in Collections in Databases                     |

---

## 📘 Final Notes

MongoDB is flexible, scalable, and powerful — but with that power comes responsibility:

* Always **index** critical queries
* Always **test restore** from backups
* Use **replication** in production, even locally for HA simulation

---



