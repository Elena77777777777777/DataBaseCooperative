
CREATE DATABASE cooperative_database;

\c cooperative_database;


CREATE TABLE Cooperative (
    CooperativeID SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    LocationDistrict VARCHAR(50),
    Profile VARCHAR(255),
    NumberOfEmployees INT,
    AuthorizedCapital DECIMAL(15, 2)
);


CREATE TABLE Membership (
    MembershipID SERIAL PRIMARY KEY,
    CooperativeID INT,
    RegistrationNumber INT,
    RegistrationDate DATE,
    FOREIGN KEY (CooperativeID) REFERENCES Cooperative(CooperativeID)
);

CREATE TABLE Owner (
    OwnerID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    PassportData VARCHAR(20),
    ResidenceDistrict VARCHAR(50)
);


CREATE USER db_owner WITH PASSWORD 'your_password';


ALTER TABLE Cooperative OWNER TO db_owner;
ALTER TABLE Membership OWNER TO db_owner;
ALTER TABLE Owner OWNER TO db_owner;
