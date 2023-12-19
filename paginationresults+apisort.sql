from fastapi import Depends, FastAPI, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, Column, Integer, String, Date
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from numpy import median
import random
import string

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
    additional_field = Column(String)  # Новое поле

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


def populate_additional_field(db: Session):
    cooperatives = db.query(Cooperative).all()
    for cooperative in cooperatives:
        random_string = ''.join(random.choices(string.ascii_letters, k=10))
        cooperative.additional_field = random_string

    db.commit()


def get_median_of_additional_field(db: Session):
    values = db.query(func.cast(Cooperative.additional_field, Integer)).all()
    values = [value[0] for value in values]
    return median(values)


def get_paginated_cooperatives(db: Session, skip: int = 0, limit: int = 10):
    return db.query(Cooperative).offset(skip).limit(limit).all()


def get_sorted_cooperatives(db: Session, sort_by: str = "name"):
    if not hasattr(Cooperative, sort_by):
        raise HTTPException(status_code=400, detail="Invalid sorting field")

    return db.query(Cooperative).order_by(getattr(Cooperative, sort_by)).all()

app = FastAPI()


@app.post("/populate_additional_field/")
def populate_additional_field_endpoint(db: Session = Depends(get_db)):
    populate_additional_field(db)
    return {"message": "Additional field populated successfully"}


@app.get("/median_of_additional_field/")
def get_median_of_additional_field_endpoint(db: Session = Depends(get_db)):
    return {"median": get_median_of_additional_field(db)}


@app.get("/cooperatives_paginated/")
def get_paginated_cooperatives_endpoint(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return get_paginated_cooperatives(db, skip=skip, limit=limit)


@app.get("/cooperatives_sorted/")
def get_sorted_cooperatives_endpoint(sort_by: str = "name", db: Session = Depends(get_db)):
    return get_sorted_cooperatives(db, sort_by=sort_by)
