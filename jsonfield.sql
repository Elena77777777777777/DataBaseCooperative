#models.py

from sqlalchemy import Column, Integer, String, Date, JSON, create_engine, text
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session
import json
import random
import string
from numpy import median

DATABASE_URL = "sqlite:///./cooperative.db"
engine = create_engine(DATABASE_URL)
Base = declarative_base()

class Cooperative(Base):
    __tablename__ = 'cooperatives'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    location_district = Column(String)
    profile = Column(String)
    number_of_employees = Column(Integer)
    authorized_capital = Column(Integer)
    establishment_date = Column(Date)
    additional_data = Column(JSON)  # Новое JSON-поле

    memberships = relationship("Membership", back_populates="cooperative")

class Membership(Base):
    __tablename__ = 'memberships'

    id = Column(Integer, primary_key=True, index=True)
    cooperative_id = Column(Integer, ForeignKey('cooperatives.id'))
    registration_number = Column(Integer, index=True)
    registration_date = Column(Date)

    cooperative = relationship("Cooperative", back_populates="memberships")

Base.metadata.create_all(bind=engine)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def populate_additional_data(db: Session):
    cooperatives = db.query(Cooperative).all()
    for cooperative in cooperatives:
        additional_data = {"field1": "value1", "field2": "value2"}
        cooperative.additional_data = json.dumps(additional_data)

    db.commit()


def create_pg_trgm_gin_index(db: Session):
    db.execute("CREATE INDEX cooperative_additional_data_trgm_gin ON cooperatives USING gin (additional_data gin_trgm_ops);")
    db.commit()


def full_text_search(pattern: str, db: Session):
    query = (
        db.query(Cooperative)
        .filter(text(f"additional_data::TEXT ~ '{pattern}'"))
        .all()
    )
    return query

app = FastAPI()


@app.post("/populate_additional_data/")
def populate_additional_data_endpoint(db: Session = Depends(get_db)):
    populate_additional_data(db)
    return {"message": "Additional data populated successfully"}


@app.post("/create_pg_trgm_gin_index/")
def create_pg_trgm_gin_index_endpoint(db: Session = Depends(get_db)):
    create_pg_trgm_gin_index(db)
    return {"message": "pg_trgm + GIN index created successfully"}


@app.get("/full_text_search/")
def full_text_search_endpoint(pattern: str, db: Session = Depends(get_db)):
    return full_text_search(pattern, db)
