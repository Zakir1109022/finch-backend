# 🔐 Secret Management in Kubernetes

This document outlines the **secret management strategy** used for the Django-based application within the Kubernetes cluster. It explains how secrets are **created**, **updated**, and **accessed** by applications and provides step-by-step instructions for applying and managing secrets securely.

---

## ⚖️ Chosen Secret Management Strategy

The application uses **Kubernetes Secrets** of type `Opaque` to manage sensitive environment variables such as database credentials, Stripe API keys, and site configuration values.

### Why Kubernetes Secrets?

* ✅ Native to Kubernetes
* ✅ Easily mountable into pods
* ✅ Base64-encoded (not encrypted by default but secured via etcd with RBAC and encryption at rest when configured)
* ✅ Version controlled through manifest files (without exposing secrets publicly)

---

## 🗂️ Secret Manifest Example

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: django-env-secret
  namespace: django-app
type: Opaque
stringData:
  POSTGRES_DB: fleetdb
  POSTGRES_USER: roy77
  POSTGRES_PASSWORD: asdf1234@77
  PYTHONUNBUFFERED: "1"
  POSTGRES_HOST: postgres
  STRIPE_SECRET_KEY: "sk_test_..."
  STRIPE_PUBLIC_KEY: "pk_test_..."
  STRIPE_WEBHOOK_SECRET: "whsec_..."
  SITE_URL: "http://93.127.195.189:5000"
  FRONTEND_SITE_URL: "https://finch-development.vercel.app"
```

---

## ✍️ How to Create and Apply Secrets

### Option 1: Apply from YAML file

```bash
kubectl apply -f django-secret.yaml
```

### Option 2: Create via CLI

```bash
kubectl create secret generic django-env-secret \
  --namespace=django-app \
  --from-literal=POSTGRES_DB=fleetdb \
  --from-literal=POSTGRES_USER=roy77 \
  --from-literal=POSTGRES_PASSWORD='asdf1234@77' \
  --from-literal=PYTHONUNBUFFERED=1 \
  --from-literal=POSTGRES_HOST=postgres \
  --from-literal=STRIPE_SECRET_KEY='sk_test_...' \
  --from-literal=STRIPE_PUBLIC_KEY='pk_test_...' \
  --from-literal=STRIPE_WEBHOOK_SECRET='whsec_...' \
  --from-literal=SITE_URL='http://93.127.195.189:5000' \
  --from-literal=FRONTEND_SITE_URL='https://finch-development.vercel.app'
```

---

## ✉️ Accessing Secrets from Deployments

Secrets are injected as **environment variables** using the `envFrom` directive:

```yaml
containers:
- name: django
  image: zakir22/finch-backend:latest
  envFrom:
  - secretRef:
      name: django-env-secret
```

Each key in the secret will be available as an environment variable inside the container.
