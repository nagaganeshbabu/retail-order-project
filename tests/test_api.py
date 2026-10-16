import os
import tempfile
from pathlib import Path

# Configure isolated DB before importing the app.
_db = tempfile.TemporaryDirectory()
os.environ["DATABASE_URL"] = "sqlite:///" + str(Path(_db.name) / "test.db")
from fastapi.testclient import TestClient
from app.main import app


def test_products_and_orders():
    with TestClient(app) as client:
        assert client.get("/health/live").status_code == 200
        assert client.get("/health/ready").status_code == 200
        response = client.post("/products", json={"name": "Keyboard", "price_cents": 2500, "stock": 3})
        assert response.status_code == 201
        product_id = response.json()["id"]
        response = client.post("/orders", json={"product_id": product_id, "quantity": 2})
        assert response.status_code == 201
        assert response.json()["total_cents"] == 5000
        assert client.post("/orders", json={"product_id": product_id, "quantity": 2}).status_code == 409
        assert client.get("/orders").json()[0]["quantity"] == 2
        assert client.get("/products").json()[0]["stock"] == 1
