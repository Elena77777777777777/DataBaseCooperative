from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, Column, Integer, String, Date
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(DATABASE_URL)

Base = declarative_base()

# Определение модели Cooperative
class Cooperative(Base):
    __tablename__ = 'cooperatives'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    location_district = Column(String)
    profile = Column(String)
    number_of_employees = Column(Integer)
    authorized_capital = Column(Integer)


Base.metadata.create_all(bind=engine)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

app = FastAPI()


# Dependency to get the database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Create operation
@app.post("/cooperatives/")
def create_cooperative(cooperative: Cooperative, db: Session = Depends(get_db)):
    db.add(cooperative)
    db.commit()
    db.refresh(cooperative)
    return cooperative


# Read operation
@app.get("/cooperatives/{cooperative_id}")
def read_cooperative(cooperative_id: int, db: Session = Depends(get_db)):
    cooperative = db.query(Cooperative).filter(Cooperative.id == cooperative_id).first()
    if cooperative is None:
        raise HTTPException(status_code=404, detail="Cooperative not found")
    return cooperative


# Update operation
@app.put("/cooperatives/{cooperative_id}")
def update_cooperative(cooperative_id: int, updated_cooperative: Cooperative, db: Session = Depends(get_db)):
    existing_cooperative = db.query(Cooperative).filter(Cooperative.id == cooperative_id).first()
    if existing_cooperative is None:
        raise HTTPException(status_code=404, detail="Cooperative not found")

    for var, value in vars(updated_cooperative).items():
        setattr(existing_cooperative, var, value) if value is not None else None

    db.commit()
    db.refresh(existing_cooperative)
    return existing_cooperative


# Delete operation
@app.delete("/cooperatives/{cooperative_id}")
def delete_cooperative(cooperative_id: int, db: Session = Depends(get_db)):
    cooperative = db.query(Cooperative).filter(Cooperative.id == cooperative_id).first()
    if cooperative is None:
        raise HTTPException(status_code=404, detail="Cooperative not found")

    db.delete(cooperative)
    db.commit()
    return {"message": "Cooperative deleted successfully"}

