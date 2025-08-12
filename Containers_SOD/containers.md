# ✅ **Introduction to Containers and Docker**

*(Theory with examples and Docker commands)*

---

## 📦 What Are Containers?

**Containers** are lightweight, isolated environments that bundle an application along with all its dependencies. This ensures that the application **runs the same** regardless of the environment—be it your local machine, a testing server, or production.

### 🔍 Key Characteristics:

* **Isolation:** Each container runs in its own process and filesystem.
* **Portability:** Containers run the same anywhere.
* **Speed:** Containers are fast to start and stop.
* **Resource-efficient:** Containers share the host OS kernel, using fewer resources than virtual machines.

---

## 🐳 What Is Docker?

**Docker** is a containerization platform that automates the creation, deployment, and management of containers.

Docker allows developers to:

* Package apps and dependencies into **Docker images**
* Run those images as **containers**
* Share images via **Docker Hub**

---

## 🛠️ Docker Components

| Component          | Description                                        |
| ------------------ | -------------------------------------------------- |
| **Docker Engine**  | The core service that runs containers              |
| **Docker CLI**     | Command-line interface to manage Docker            |
| **Dockerfile**     | Script to build Docker images                      |
| **Docker Hub**     | Public image repository                            |
| **Docker Compose** | Tool for defining and running multi-container apps |

---

## 🔧 Basic Docker Commands (with Examples)

### 1. `docker --version`

Check Docker installation.

```bash
docker --version
```

---

### 2. `docker run`

Run a container from an image (downloads if not present).

```bash
docker run hello-world
```

This runs a test image that confirms Docker is working.

---

### 3. `docker pull`

Download an image from Docker Hub.

```bash
docker pull nginx
```

---

### 4. `docker images`

List locally stored images.

```bash
docker images
```

---

### 5. `docker ps`

List running containers.

```bash
docker ps
```

To see all containers (running and stopped):

```bash
docker ps -a
```

---

### 6. `docker stop` / `docker start`

Stop or start a running container.

```bash
docker stop <container_id>
docker start <container_id>
```

---

### 7. `docker rm` / `docker rmi`

Remove container or image.

```bash
docker rm <container_id>
docker rmi <image_id>
```

---

### 8. `docker exec`

Run a command inside a running container.

```bash
docker exec -it <container_id> bash
```

Example: log into a running Ubuntu container.

---

### 9. `docker build`

Build an image from a Dockerfile.

```bash
docker build -t my-image .
```

---

### 10. `docker tag`

Tag an image with a name for sharing.

```bash
docker tag my-image username/my-image:1.0
```

---

### 11. `docker push`

Push your image to Docker Hub.

```bash
docker push username/my-image:1.0
```

---

### 12. `docker logs`

View the output logs of a container.

```bash
docker logs <container_id>
```

---

### 13. `docker volume`

Create and manage volumes (persistent data).

```bash
docker volume create my-volume
```

Mounting it:

```bash
docker run -v my-volume:/app/data my-image
```

---
## 🎯 Why Use Docker?

* Consistency across environments
* Easy onboarding and reproducibility
* Better CI/CD integration
* Resource isolation and efficiency

---

## ✅ Summary

| Concept                          | Example                     |
| -------------------------------- | --------------------------- |
| Run a container                  | `docker run ubuntu`         |
| Build image                      | `docker build -t my-app .`  |
| List containers                  | `docker ps -a`              |
| Execute command inside container | `docker exec -it <id> bash` |
| Docker Compose start             | `docker-compose up`         |

Docker simplifies the entire software lifecycle: **build, ship, run**.

---
# 📄 **Dockerfile**

## ✅ What Is a Dockerfile?

A **Dockerfile** is a simple **text file** that contains a set of instructions to build a **Docker image**. Each instruction describes how to construct the environment and application that will eventually run in a container.

---

## 🧱 Why Use a Dockerfile?

* Automates the creation of Docker images
* Ensures **reproducibility** and **consistency**
* Works well with CI/CD pipelines
* Acts as documentation for how to set up your app

---

## 📘 Common Dockerfile Instructions

| Instruction | Purpose                                         |
| ----------- | ----------------------------------------------- |
| `FROM`      | Base image (starting point)                     |
| `WORKDIR`   | Sets the working directory inside the container |
| `COPY`      | Copies files from host into container           |
| `RUN`       | Executes a command at build time                |
| `CMD`       | Default command to run when container starts    |
| `EXPOSE`    | Documents the port the container listens on     |
| `ENV`       | Set environment variables                       |

---

## 🧪 Dockerfile Example (Node.js App)

**Project structure:**

```
/app
├── Dockerfile
├── package.json
├── index.js
```

**Dockerfile:**

```Dockerfile
# 1. Use official Node.js base image
FROM node:18

# 2. Set working directory
WORKDIR /app

# 3. Copy files
COPY package*.json ./
COPY . .

# 4. Install dependencies
RUN npm install

# 5. Expose port
EXPOSE 3000

# 6. Start the app
CMD ["node", "index.js"]
```

**Build and Run:**

```bash
docker build -t my-node-app .
docker run -p 3000:3000 my-node-app
```

---

# 📦 **Docker Compose**

## ✅ What Is Docker Compose?

**Docker Compose** is a tool for defining and running **multi-container Docker applications**. Instead of running multiple `docker run` commands, you define all your services in a single **`docker-compose.yml`** file.

---

## 💡 Why Use Docker Compose?

* Manages multiple containers easily
* Defines dependencies and configurations in one place
* Supports **volumes**, **networks**, and **environment variables**
* Great for development environments (e.g. app + database + cache)

---

## 📘 Common Compose Keywords

| Keyword       | Purpose                        |
| ------------- | ------------------------------ |
| `version`     | Compose file version           |
| `services`    | Defines containerized services |
| `image`       | Use an image from Docker Hub   |
| `build`       | Build from a local Dockerfile  |
| `ports`       | Map container ports to host    |
| `volumes`     | Mount volumes                  |
| `depends_on`  | Define startup order           |
| `environment` | Set environment variables      |

---

## 🧪 Docker Compose Example (Node App + MongoDB)

**Directory structure:**

```
/myapp
├── docker-compose.yml
├── Dockerfile
├── package.json
├── index.js
```

**Dockerfile** (same as above):

```Dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "index.js"]
```

**docker-compose.yml:**

```yaml
version: "3"
services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - mongo

  mongo:
    image: mongo
    ports:
      - "27017:27017"
```

---

## 🚀 Usage Commands

```bash
# Start all services
docker-compose up

# Start in detached mode
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs

# Rebuild after changes
docker-compose up --build
```

---

## 🧩 Example Output

When you run `docker-compose up`, it will:

1. Build the image for your app from the Dockerfile
2. Pull the MongoDB image
3. Run both containers
4. Link them via an internal Docker network

---

## 📝 Summary

| Feature     | Dockerfile                     | Docker Compose                              |
| ----------- | ------------------------------ | ------------------------------------------- |
| Purpose     | Build a single container image | Define and run multi-container applications |
| Format      | Text file (`Dockerfile`)       | YAML file (`docker-compose.yml`)            |
| Example Use | Node.js app container          | Node.js + MongoDB service setup             |



