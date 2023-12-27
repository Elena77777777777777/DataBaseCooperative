from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey, func
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from . import crud, models

DATABASE_URL = "sqlite:///./cooperative.db"
engine = create_engine(DATABASE_URL)
Base = declarative_base()
Base.metadata.create_all(bind=engine)

app = FastAPI()

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

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# SELECT ... WHERE
@app.get("/cooperatives/")
def get_cooperatives_with_conditions(
    name: str = None,
    location_district: str = None,
    profile: str = None,
    db: Session = Depends(crud.get_db)
):
    return crud.get_cooperatives_with_conditions(db, name, location_district, profile)

# JOIN
@app.get("/cooperatives_with_members/")
def get_cooperatives_with_members(db: Session = Depends(crud.get_db)):
    return crud.get_cooperatives_with_members(db)

# UPDATE
@app.put("/update_employees/")
def update_employees_by_profile(profile: str, new_number_of_employees: int, db: Session = Depends(crud.get_db)):
    return crud.update_employees_by_profile(db, profile, new_number_of_employees)

# GROUP BY
@app.get("/cooperatives_group_by_profile/")
def get_cooperatives_group_by_profile(db: Session = Depends(crud.get_db)):
    return db.query(models.Cooperative.profile, func.count(models.Cooperative.id)).group_by(models.Cooperative.profile).all()

# SELECT
@app.get("/cooperatives_with_most_members/")
def get_cooperatives_with_most_members(db: Session = Depends(crud.get_db)):
    return db.query(models.Cooperative).filter(models.Cooperative.id == (
        db.query(models.Membership.cooperative_id)
        .group_by(models.Membership.cooperative_id)
        .order_by(func.count(models.Membership.id).desc())
        .limit(1)
    )).all()

#Median
@app.get("/median_of_additional_field/")
def get_median_of_additional_field(db: Session = Depends(crud.get_db)):
    return crud.get_median_of_additional_field(db)

#Pagination
@app.get("/cooperatives_paginated/")
def get_paginated_cooperatives(skip: int = 0, limit: int = 10, db: Session = Depends(crud.get_db)):
    return crud.get_paginated_cooperatives(db, skip=skip, limit=limit)

#Sort
@app.get("/cooperatives_sorted/")
def get_sorted_cooperatives(sort_by: str = "name", db: Session = Depends(crud.get_db)):
    return crud.get_sorted_cooperatives(db, sort_by=sort_by)
