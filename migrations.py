# schema.py

from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship, sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from alembic import op
import sqlalchemy as sa

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


class Owner(Base):
    __tablename__ = 'owners'

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    address = Column(String)
    passport_data = Column(String)
    residence_district = Column(String)


Base.metadata.create_all(bind=engine)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# alembic/versions/xxxxxx_add_additional_field_to_cooperative.py

def upgrade():
    op.add_column('cooperatives', sa.Column('additional_field', sa.String))

def downgrade():
    op.drop_column('cooperatives', 'additional_field')

# alembic/versions/yyyyyy_add_index_on_name.py

def upgrade():
    op.create_index('ix_cooperatives_name', 'cooperatives', ['name'])

def downgrade():
    op.drop_index('ix_cooperatives_name', 'cooperatives')
