# 🚧 Docker Containerization for Finch Backend

This document explains the **Dockerfile structure**, **image optimization techniques**, and how to **build and run the Docker image locally** for the Django-based Finch Backend application.

---

## 🔧 Dockerfile Overview

The Dockerfile uses a **multi-stage build** strategy to create a lightweight production image.

### Stage 1: `builder`

* **Base Image**: `ubuntu:22.04`
* **Purpose**: Build and install Python dependencies
* **Key Steps**:

  * Installs build dependencies (`python3-dev`, `build-essential`, `libpq-dev`, etc.)
  * Sets up a Python virtual environment: `venv1`
  * Installs dependencies from `requirements.txt`

```dockerfile
FROM ubuntu:22.04 AS builder
WORKDIR /app
RUN apt-get update && apt-get install ...
COPY requirements.txt .
RUN python3 -m venv venv1 && ...
```

### Stage 2: `production`

* **Base Image**: `ubuntu:22.04`
* **Purpose**: Run the Django app using the minimal runtime environment
* **Key Steps**:

  * Installs only runtime packages (`python3`, `libpq5`, etc.)
  * Copies the virtual environment and source code from the builder
  * Creates a non-root user (`appuser`) for better security
  * Launches the app using Django's development server

```dockerfile
FROM ubuntu:22.04 AS production
WORKDIR /app
RUN apt-get update && apt-get install ...
COPY --from=builder /app/venv1 /app/venv1
COPY . /app/
USER appuser
CMD ["/bin/bash", "-c", "source venv1/bin/activate && ..."]
```

---

## ⚖️ Image Optimization Techniques

| Technique                 | Description                                             |
| ------------------------- | ------------------------------------------------------- |
| Multi-stage build         | Separates build and runtime for a smaller final image   |
| Clean apt cache           | `apt-get clean && rm -rf /var/lib/apt/lists/*`          |
| Virtual environment reuse | Only copies needed Python dependencies                  |
| Minimal packages          | Uses `--no-install-recommends` for lighter installs     |
| Non-root user             | Enhances security by avoiding `root` in the final image |

---

## 🔄 Build the Docker Image Locally

```bash
docker build -t finch-backend:latest .
```

---

## ▶️ Run the Docker Container Locally

### Example: With default settings

```bash
docker run -p 8000:8000 finch-backend:latest
```

### Example: With environment variables

```bash
docker run --env-file .env -p 8000:8000 finch-backend:latest
```

> The `CMD` in the Dockerfile runs:

```bash
source venv1/bin/activate && python manage.py migrate && python manage.py createsuperuser --noinput && python manage.py runserver 0.0.0.0:8000
```
