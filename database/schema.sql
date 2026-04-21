USE ScubaDB;
GO

CREATE TABLE Divers (
    Diver_ID       INT            IDENTITY(1,1) PRIMARY KEY,
    First_Name     VARCHAR(50)    NOT NULL,
    Last_Name      VARCHAR(50)    NOT NULL,
    Date_of_Birth  DATE,
    Email          VARCHAR(100),
    Phone          VARCHAR(20),
    Is_Removed     BIT            DEFAULT 0
);

CREATE TABLE Certification_Agencies (
    Agency_ID    INT           IDENTITY(1,1) PRIMARY KEY,
    Agency_Name  VARCHAR(100)  NOT NULL
);

CREATE TABLE Instructors (
    Instructor_ID      INT           IDENTITY(1,1) PRIMARY KEY,
    First_Name         VARCHAR(50)   NOT NULL,
    Last_Name          VARCHAR(50)   NOT NULL,
    Instructor_Number  VARCHAR(50),
    Agency_ID          INT,
    Is_Removed         BIT           DEFAULT 0,

    FOREIGN KEY (Agency_ID) REFERENCES Certification_Agencies(Agency_ID)
);

CREATE TABLE Certifications (
    Certification_ID    INT           IDENTITY(1,1) PRIMARY KEY,
    Certification_Name  VARCHAR(100)  NOT NULL,
    Agency_ID           INT,

    FOREIGN KEY (Agency_ID) REFERENCES Certification_Agencies(Agency_ID)
);

CREATE TABLE Diver_Certifications (
    Diver_Certification_ID  INT           IDENTITY(1,1) PRIMARY KEY,
    Diver_ID                INT,
    Certification_ID        INT,
    Instructor_ID           INT,
    Certification_Number    VARCHAR(50), 
    Date_Issued             DATE,

    FOREIGN KEY (Diver_ID) REFERENCES Divers(Diver_ID),
    FOREIGN KEY (Certification_ID) REFERENCES Certifications(Certification_ID),
    FOREIGN KEY (Instructor_ID) REFERENCES Instructors(Instructor_ID)
);

CREATE TABLE Dive_Sites (
    Site_ID     INT            IDENTITY(1,1) PRIMARY KEY,
    Site_Name   VARCHAR(100),
    [Location]  VARCHAR(100),
    Max_Depth   INT,
    Is_Removed  BIT            DEFAULT 0
);

CREATE TABLE Dive_Sessions (
    Session_ID        INT    IDENTITY(1,1) PRIMARY KEY,
    Diver_ID          INT,
    Session_Date      DATE,
    Surface_Interval  INT,

    FOREIGN KEY (Diver_ID) REFERENCES Divers(Diver_ID)
);

CREATE TABLE Dive_Logs (
    Dive_ID      INT   IDENTITY(1,1) PRIMARY KEY,
    Session_ID   INT,
    Site_ID      INT,
    Dive_Number  INT,
    Max_Depth    INT,
    Bottom_Time  INT,

    FOREIGN KEY (Session_ID) REFERENCES Dive_Sessions(Session_ID),
    FOREIGN KEY (Site_ID) REFERENCES Dive_Sites(Site_ID)
);