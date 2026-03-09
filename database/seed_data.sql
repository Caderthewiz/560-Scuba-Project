USE ScubaDB;
GO

INSERT INTO Certification_Agencies (Agency_Name)
VALUES
('PADI'),
('NAUI'),
('SSI');

INSERT INTO Certifications (Certification_Name, Agency_ID)
VALUES
('Open Water Diver', 1),
('Advanced Open Water', 1),
('Rescue Diver', 1);

INSERT INTO Divers (First_Name, Last_Name, Date_of_Birth, Email)
VALUES
('John', 'Doe', '1990-05-14', 'john@example.com'),
('Jane', 'Smith', '1995-08-22', 'jane@example.com');

INSERT INTO Dive_Sites (Site_Name, Location, Max_Depth)
VALUES
('Blue Grotto', 'Florida', 100),
('Devils Den', 'Florida', 60);

INSERT INTO Dive_Sessions (Diver_ID, Session_Date, Surface_Interval)
VALUES
(1, '2024-05-10', 60);

INSERT INTO Dive_Logs (Session_ID, Site_ID, Dive_Number, Max_Depth, Bottom_Time)
VALUES
(1, 1, 1, 60, 45),
(1, 2, 2, 50, 40);