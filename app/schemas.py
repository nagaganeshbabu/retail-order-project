from pydantic import BaseModel, Field, ConfigDict

class ProductCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    price_cents: int = Field(gt=0)
    stock: int = Field(ge=0)

class ProductOut(ProductCreate):
    id: int
    model_config = ConfigDict(from_attributes=True)

class OrderCreate(BaseModel):
    product_id: int = Field(gt=0)
    quantity: int = Field(gt=0, le=100)

class OrderOut(BaseModel):
    id: int
    product_id: int
    quantity: int
    total_cents: int
    status: str
    model_config = ConfigDict(from_attributes=True)
