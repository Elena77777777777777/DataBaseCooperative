-- Таблица "Cooperative" (Кооператив)
CREATE TABLE Cooperative (
    CooperativeID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    LocationDistrict VARCHAR(50),
    Profile VARCHAR(255),
    NumberOfEmployees INT,
    AuthorizedCapital DECIMAL(15, 2)
);

-- Таблица "Membership" (Членство)
CREATE TABLE Membership (
    MembershipID INT PRIMARY KEY,
    CooperativeID INT,
    RegistrationNumber INT,
    RegistrationDate DATE,
    FOREIGN KEY (CooperativeID) REFERENCES Cooperative(CooperativeID)
);

-- Таблица "Owner" (Владелец)
CREATE TABLE Owner (
    OwnerID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    PassportData VARCHAR(20),
    ResidenceDistrict VARCHAR(50)
);
