# Kubernetes\_Architecture.md

## Overview

This document outlines the Kubernetes architecture used to deploy a Django-based web application with a PostgreSQL backend. It includes explanations of the namespace strategy, secret management, persistent volume claim for PostgreSQL, deployment and service definitions for both the database and application, and scaling strategies.

---

## Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: django-app
```

Namespaces logically isolate application environments. The `django-app` namespace separates resources related to the Django application from other workloads in the cluster.

---

## Secret Management

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: django-env-secret
  namespace: django-app
type: Opaque
stringData:
  ...
```

Secrets are used to store sensitive information such as database credentials and API keys. These secrets are referenced in both the Django and PostgreSQL deployments to avoid hardcoding values in manifests.

---

## PersistentVolumeClaim (PVC)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: django-app
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

The PVC ensures PostgreSQL data persists beyond container lifecycles. `ReadWriteOnce` allows the volume to be mounted as read-write by a single node.

---

## PostgreSQL Deployment and Service

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
spec:
  replicas: 1
  ...
```

The `postgres` deployment initializes a single replica with environment variables injected via secrets. The container uses a readiness probe with `pg_isready` to verify database availability.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  type: ClusterIP
  ports:
    - port: 5432
  selector:
    app: postgres
```

The corresponding service exposes PostgreSQL internally via ClusterIP on port 5432, allowing Django to connect using the DNS name `postgres.django-app.svc.cluster.local`.

---

## Django Deployment and Service

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: django
spec:
  replicas: 1
  ...
```

The Django app runs as a container pulling the latest image from Docker Hub. Environment variables are sourced from the secret.

Health checks (`readinessProbe` and `livenessProbe`) monitor the `/login` route for uptime and auto-recovery.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: django
spec:
  selector:
    app: django
  ports:
    - port: 8000
      targetPort: 8000
```

The Django service exposes the app on port 8000 internally.

---

##  **Resource Allocation**

### Deployment Resources
The Vue application deployment defines specific **CPU and memory resources** for efficient usage and to avoid overcommitment of cluster resources.

- **Requests**:
  - CPU: `500m` (0.5 vCPU)
  - Memory: `512Mi`
  - These values define the minimum resources guaranteed to the container.
  
- **Limits**:
  - CPU: `1` (1 vCPU)
  - Memory: `1Gi`
  - These are the maximum resources the container can consume.
```
