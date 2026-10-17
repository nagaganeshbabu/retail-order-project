import logging
import os
from contextlib import asynccontextmanager
from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy import select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from app.db import Base, SessionLocal, engine
from app.models import Product, Order
from app.schemas import ProductCreate, ProductOut, OrderCreate, OrderOut

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger("orders-api")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Learning convenience only: use versioned migrations in production.
    Base.metadata.create_all(bind=engine)
    yield

app = FastAPI(title="Retail Orders API", version="1.0.0", lifespan=lifespan)

def get_db():
    with SessionLocal() as session:
        yield session

@app.get("/health/live")
def live():
    return {"status": "alive"}

@app.get("/health/ready")
def ready(db: Session = Depends(get_db)):
    db.execute(select(1))
    return {"status": "ready"}

@app.post("/products", response_model=ProductOut, status_code=201)
def add_product(payload: ProductCreate, db: Session = Depends(get_db)):
    product = Product(**payload.model_dump())
    db.add(product)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, "Product name already exists")
    db.refresh(product)
    return product

@app.get("/products", response_model=list[ProductOut])
def list_products(db: Session = Depends(get_db)):
    return db.scalars(select(Product).order_by(Product.id)).all()

@app.post("/orders", response_model=OrderOut, status_code=201)
def create_order(payload: OrderCreate, db: Session = Depends(get_db)):
    # Atomic stock deduction avoids overselling with concurrent requests.
    result = db.execute(update(Product).where(Product.id == payload.product_id, Product.stock >= payload.quantity).values(stock=Product.stock - payload.quantity))
    if result.rowcount != 1:
        db.rollback()
        product = db.get(Product, payload.product_id)
        raise HTTPException(404 if product is None else 409, "Product not found" if product is None else "Insufficient stock")
    product = db.get(Product, payload.product_id)
    order = Order(product_id=product.id, quantity=payload.quantity, total_cents=product.price_cents * payload.quantity, status="created")
    db.add(order)
    db.commit()
    db.refresh(order)
    logger.info("created order id=%s", order.id)
    return order

@app.get("/orders", response_model=list[OrderOut])
def list_orders(db: Session = Depends(get_db)):
    return db.scalars(select(Order).order_by(Order.id)).all()

@app.get("/orders/{order_id}", response_model=OrderOut)
def get_order(order_id: int, db: Session = Depends(get_db)):
    order = db.get(Order, order_id)
    if order is None:
        raise HTTPException(404, "Order not found")
    return order


"here i am writhing for the cicd piple line  "
