# Retail Orders API — GCP DevOps practice project

A medium-sized **learning** backend for a retail ordering workflow. Includes products, stock validation, orders, health checks, Docker, tests, Kubernetes YAML, and GitHub Actions CI.

**Not production-ready.** No authentication, authorization, rate limits, database migrations, audit trail, payment integration, or persistent GKE database configuration. This project does **not** process real payments.

## Architecture

Developer code -> GitHub -> CI tests -> Docker image -> Artifact Registry -> GKE Deployment -> ClusterIP Service -> Pods.

## API endpoints

| Method | Path | Purpose |
|---|---|---|
| GET | `/health/live` | Liveness |
| GET | `/health/ready` | Database readiness |
| POST | `/products` | Create a product |
| GET | `/products` | List products |
| POST | `/orders` | Place an order, deduct stock |
| GET | `/orders` | List orders |
| GET | `/orders/{id}` | Read an order |
| GET | `/docs` | Interactive Swagger UI |

## Run in VS Code (terminal)

```bash
python -m venv .venv
# Linux/macOS: source .venv/bin/activate
# Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
uvicorn app.main:app --reload
```

Open `http://localhost:8000/docs`. Run tests with `pytest -q`.

Example product request:

```json
{"name":"Keyboard","price_cents":2500,"stock":10}
```

Example order request:

```json
{"product_id":1,"quantity":2}
```

## Build container locally

```bash
docker build -t retail-orders:v1 .
docker run --rm -p 8000:8000 -e DATABASE_URL=sqlite:////tmp/orders.db retail-orders:v1
```

SQLite data in the container is **temporary**. Restarting the container loses data.

## Push project to your own GitHub repository

Create an empty GitHub repository (do not initialize it with README), then:

```bash
git init
git add .
git commit -m "Initial retail orders application"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/retail-orders-project.git
git push -u origin main
```

GitHub authentication requires an appropriate sign-in method (credential manager or SSH); account passwords are not accepted for Git pushes.

## GCP deployment — next stage

1. Ensure you have an approved GCP project and GKE cluster.
2. Enable Artifact Registry and create a Docker repository.
3. Build and push the image to Artifact Registry (Cloud Build or Docker).
4. Replace `IMAGE_PLACEHOLDER` in `k8s/deployment.yaml` with the full registry image path.
5. `kubectl apply -f k8s/deployment.yaml`
6. `kubectl rollout status deployment/retail-orders`
7. `kubectl port-forward service/retail-orders 8000:8000` and test in a second terminal.

The sample Kubernetes manifest runs **one replica only** with ephemeral SQLite storage. It is for understanding the deployment workflow, not production data.

## Before any real production release

Use a managed PostgreSQL database (e.g., Cloud SQL) and schema migrations; configure Workload Identity, Secret Manager, least-privilege IAM, private networking, proper CI/CD approvals, immutable image digests, security scanning, auth/RBAC, HTTPS ingress, observability, backup/recovery, HA, HPA, and tested rollback procedures. Do not expose the sample endpoints to the public internet without authentication.
