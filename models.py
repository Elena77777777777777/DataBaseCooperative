from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy_utils import create_database, database_exists
from datetime import date

# Замените 'sqlite:///example.db' на ваше соединение с базой данных
DATABASE_URL = 'sqlite:///example.db'

# Проверка на существование базы данных, иначе создание
if not database_exists(DATABASE_URL):
    create_database(DATABASE_URL)

# Создание экземпляра базы данных
engine = create_engine(DATABASE_URL, echo=True)
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

    # Определение отношения с таблицей Membership
    memberships = relationship("Membership", back_populates="cooperative")


# Определение модели Membership
class Membership(Base):
    __tablename__ = 'memberships'

    id = Column(Integer, primary_key=True, index=True)
    cooperative_id = Column(Integer, ForeignKey('cooperatives.id'))
    registration_number = Column(Integer, index=True)
    registration_date = Column(Date)

    # Определение обратного отношения с таблицей Cooperative
    cooperative = relationship("Cooperative", back_populates="memberships")


# Создание таблиц в базе данных
Base.metadata.create_all(bind=engine)
