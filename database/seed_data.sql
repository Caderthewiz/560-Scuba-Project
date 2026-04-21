-- ============================================================
-- seed_data.sql  –  Randomized seed data using T-SQL loops
-- Generates: 3 agencies, 9 certifications, 20 instructors,
--            50 divers, 15 dive sites, ~150 diver certs,
--            100 dive sessions, ~250 dive logs
-- ============================================================
USE ScubaDB;
GO

-- ============================================================
--  SECTION 1: STATIC REFERENCE DATA
--  Agencies, certifications, and sites have no dependencies
--  so they are inserted as fixed, realistic values first.
-- ============================================================

INSERT INTO Certification_Agencies (Agency_Name) VALUES
('PADI'),
('NAUI'),
('SSI');

INSERT INTO Certifications (Certification_Name, Agency_ID) VALUES
('Open Water Diver',        1),
('Advanced Open Water',     1),
('Rescue Diver',            1),
('Divemaster',              1),
('Open Water Diver',        2),
('Advanced Scuba Diver',    2),
('Rescue Diver',            2),
('Open Water Diver',        3),
('Advanced Open Water',     3);

INSERT INTO Dive_Sites (Site_Name, Location, Max_Depth) VALUES
('Blue Grotto',         'Florida, USA',           100),
('Devils Den',          'Florida, USA',            60),
('SS Thistlegorm',      'Red Sea, Egypt',           30),
('Great Blue Hole',     'Belize',                  125),
('Cenote Dos Ojos',     'Yucatan, Mexico',          60),
('Silfra Fissure',      'Iceland',                  63),
('Liberty Wreck',       'Tulamben, Bali',           30),
('Richelieu Rock',      'Thailand',                 35),
('Blue Corner Wall',    'Palau',                    40),
('Shark Ray Alley',     'Belize',                   12),
('Molokini Crater',     'Hawaii, USA',              60),
('Neptune Islands',     'South Australia',          22),
('Chuuk Lagoon',        'Micronesia',               65),
('Gordon Rocks',        'Galapagos, Ecuador',       32),
('Cathedral Rock',      'Azores, Portugal',         28);

GO

-- ============================================================
--  SECTION 2: TEMP TABLES FOR RANDOM NAME POOLS
-- ============================================================

CREATE TABLE #FirstNames (ID INT IDENTITY(1,1), Name VARCHAR(50));
CREATE TABLE #LastNames  (ID INT IDENTITY(1,1), Name VARCHAR(50));

INSERT INTO #FirstNames (Name) VALUES
('James'),('Sofia'),('Marcus'),('Priya'),('Lena'),('Ethan'),('Ava'),
('Noah'),('Isabella'),('Lucas'),('Mia'),('Oliver'),('Emma'),('Liam'),
('Charlotte'),('Benjamin'),('Amelia'),('Elijah'),('Harper'),('Mason'),
('Evelyn'),('Logan'),('Abigail'),('Alexander'),('Emily'),('Jacob'),
('Elizabeth'),('Michael'),('Mila'),('Daniel'),('Ella'),('Henry'),
('Scarlett'),('Jackson'),('Victoria'),('Sebastian'),('Aria'),('Aiden'),
('Grace'),('Matthew'),('Chloe'),('Samuel'),('Penelope'),('David'),
('Layla'),('Joseph'),('Riley'),('Carter'),('Zoey'),('Owen');

INSERT INTO #LastNames (Name) VALUES
('Navarro'),('Reyes'),('Thorn'),('Fischer'),('Chen'),('Brooks'),
('Kwan'),('Petrov'),('Santos'),('Okafor'),('Nguyen'),('Larson'),
('Mehta'),('Rivera'),('Patel'),('Thompson'),('Garcia'),('Martinez'),
('Anderson'),('Wilson'),('Taylor'),('Moore'),('Jackson'),('White'),
('Harris'),('Clark'),('Lewis'),('Robinson'),('Walker'),('Hall'),
('Young'),('Allen'),('King'),('Wright'),('Scott'),('Torres'),
('Flores'),('Green'),('Adams'),('Nelson'),('Baker'),('Carter'),
('Mitchell'),('Perez'),('Roberts'),('Turner'),('Phillips'),('Campbell'),
('Parker'),('Evans');

GO

-- ============================================================
--  SECTION 3: GENERATE 20 INSTRUCTORS
--  Each gets a random agency and a unique instructor number.
-- ============================================================

DECLARE @i          INT = 1;
DECLARE @AgencyID   INT;
DECLARE @FirstName  VARCHAR(50);
DECLARE @LastName   VARCHAR(50);
DECLARE @InstrNum   VARCHAR(50);
DECLARE @Acronym    VARCHAR(10);

WHILE @i <= 20
BEGIN
    SELECT TOP 1 @AgencyID   = Agency_ID   FROM Certification_Agencies ORDER BY NEWID();
    SELECT TOP 1 @FirstName  = Name        FROM #FirstNames             ORDER BY NEWID();
    SELECT TOP 1 @LastName   = Name        FROM #LastNames              ORDER BY NEWID();
    SELECT       @Acronym    = Agency_Name FROM Certification_Agencies  WHERE Agency_ID = @AgencyID;

    SET @Acronym  = LEFT(@Acronym, 4);
    SET @InstrNum = @Acronym + '-' + CAST(10000 + @i AS VARCHAR);

    INSERT INTO Instructors (First_Name, Last_Name, Instructor_Number, Agency_ID)
    VALUES (@FirstName, @LastName, @InstrNum, @AgencyID);

    SET @i = @i + 1;
END;

GO

-- ============================================================
--  SECTION 4: GENERATE 50 DIVERS
--  Random names, DOBs between 1970 and 2003, random contact.
-- ============================================================

DECLARE @i          INT = 1;
DECLARE @FirstName  VARCHAR(50);
DECLARE @LastName   VARCHAR(50);
DECLARE @DOB        DATE;
DECLARE @Email      VARCHAR(100);
DECLARE @Phone      VARCHAR(20);
DECLARE @BirthYear  INT;
DECLARE @BirthMonth INT;
DECLARE @BirthDay   INT;

WHILE @i <= 50
BEGIN
    SELECT TOP 1 @FirstName = Name FROM #FirstNames ORDER BY NEWID();
    SELECT TOP 1 @LastName  = Name FROM #LastNames  ORDER BY NEWID();

    SET @BirthYear  = 1970 + ABS(CHECKSUM(NEWID())) % 34;
    SET @BirthMonth = 1    + ABS(CHECKSUM(NEWID())) % 12;
    SET @BirthDay   = 1    + ABS(CHECKSUM(NEWID())) % 28;
    SET @DOB        = DATEFROMPARTS(@BirthYear, @BirthMonth, @BirthDay);

    SET @Email = LOWER(@FirstName) + '.' + LOWER(@LastName)
                 + CAST(@i AS VARCHAR) + '@mail.com';

    SET @Phone = '555-'
                 + RIGHT('000'  + CAST(100 + ABS(CHECKSUM(NEWID())) % 900  AS VARCHAR), 3)
                 + '-'
                 + RIGHT('0000' + CAST(      ABS(CHECKSUM(NEWID())) % 10000 AS VARCHAR), 4);

    INSERT INTO Divers (First_Name, Last_Name, Date_of_Birth, Email, Phone)
    VALUES (@FirstName, @LastName, @DOB, @Email, @Phone);

    SET @i = @i + 1;
END;

GO

-- ============================================================
--  SECTION 5: GENERATE ~150 DIVER CERTIFICATIONS
--  Iterates over every diver and assigns 1–4 random certs.
--  Instructor is matched to the same agency as the cert.
--  Duplicate (Diver, Cert) pairs are skipped.
-- ============================================================

DECLARE @i          INT = 1;
DECLARE @DiverID    INT;
DECLARE @CertID     INT;
DECLARE @CertAgency INT;
DECLARE @InstrID    INT;
DECLARE @CertNum    VARCHAR(50);
DECLARE @IssueDate  DATE;
DECLARE @IssueYear  INT;
DECLARE @IssueMonth INT;
DECLARE @IssueDay   INT;
DECLARE @NumCerts   INT;
DECLARE @j          INT;
DECLARE @MinDiverID INT;

SELECT @MinDiverID = MIN(Diver_ID) FROM Divers;

WHILE @i <= 50
BEGIN
    SET @DiverID  = @MinDiverID + @i - 1;
    SET @NumCerts = 1 + ABS(CHECKSUM(NEWID())) % 4;
    SET @j        = 1;

    WHILE @j <= @NumCerts
    BEGIN
        SELECT TOP 1
            @CertID     = Certification_ID,
            @CertAgency = Agency_ID
        FROM Certifications
        ORDER BY NEWID();

        -- Match instructor to cert agency; fall back to any instructor if needed
        SELECT TOP 1 @InstrID = Instructor_ID
        FROM Instructors
        WHERE Agency_ID = @CertAgency
        ORDER BY NEWID();

        IF @InstrID IS NULL
            SELECT TOP 1 @InstrID = Instructor_ID FROM Instructors ORDER BY NEWID();

        SET @IssueYear  = 2018 + ABS(CHECKSUM(NEWID())) % 7;
        SET @IssueMonth = 1    + ABS(CHECKSUM(NEWID())) % 12;
        SET @IssueDay   = 1    + ABS(CHECKSUM(NEWID())) % 28;
        SET @IssueDate  = DATEFROMPARTS(@IssueYear, @IssueMonth, @IssueDay);
        SET @CertNum    = 'C-' + RIGHT('000000' + CAST(@DiverID * 100 + @j AS VARCHAR), 6);

        IF NOT EXISTS (
            SELECT 1 FROM Diver_Certifications
            WHERE Diver_ID = @DiverID AND Certification_ID = @CertID
        )
        BEGIN
            INSERT INTO Diver_Certifications
                (Diver_ID, Certification_ID, Instructor_ID, Certification_Number, Date_Issued)
            VALUES
                (@DiverID, @CertID, @InstrID, @CertNum, @IssueDate);
        END

        SET @j = @j + 1;
    END

    SET @i = @i + 1;
END;

GO

-- ============================================================
--  SECTION 6: GENERATE 100 DIVE SESSIONS
--  Random diver, random date between 2021 and 2024.
--  Surface interval is NULL ~33% of the time (first dive).
-- ============================================================

DECLARE @i           INT = 1;
DECLARE @DiverID     INT;
DECLARE @SessionDate DATE;
DECLARE @SessionYear  INT;
DECLARE @SessionMonth INT;
DECLARE @SessionDay   INT;
DECLARE @SurfaceInt   INT;

WHILE @i <= 100
BEGIN
    SELECT TOP 1 @DiverID = Diver_ID FROM Divers ORDER BY NEWID();

    SET @SessionYear  = 2021 + ABS(CHECKSUM(NEWID())) % 4;
    SET @SessionMonth = 1    + ABS(CHECKSUM(NEWID())) % 12;
    SET @SessionDay   = 1    + ABS(CHECKSUM(NEWID())) % 28;
    SET @SessionDate  = DATEFROMPARTS(@SessionYear, @SessionMonth, @SessionDay);

    SET @SurfaceInt = CASE
        WHEN ABS(CHECKSUM(NEWID())) % 3 = 0 THEN NULL
        ELSE 30 + ABS(CHECKSUM(NEWID())) % 91
    END;

    INSERT INTO Dive_Sessions (Diver_ID, Session_Date, Surface_Interval)
    VALUES (@DiverID, @SessionDate, @SurfaceInt);

    SET @i = @i + 1;
END;

GO

-- ============================================================
--  SECTION 7: GENERATE ~250 DIVE LOGS
--  Uses a cursor over all sessions. Each session gets 1–3
--  dives at random sites. Depth is capped to the site max.
-- ============================================================

DECLARE @SessionID  INT;
DECLARE @SiteID     INT;
DECLARE @SiteMax    INT;
DECLARE @MaxDepth   INT;
DECLARE @BottomTime INT;
DECLARE @NumDives   INT;
DECLARE @j          INT;

DECLARE session_cursor CURSOR FOR
    SELECT Session_ID FROM Dive_Sessions;

OPEN session_cursor;
FETCH NEXT FROM session_cursor INTO @SessionID;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @NumDives = 1 + ABS(CHECKSUM(NEWID())) % 3;
    SET @j        = 1;

    WHILE @j <= @NumDives
    BEGIN
        SELECT TOP 1
            @SiteID  = Site_ID,
            @SiteMax = Max_Depth
        FROM Dive_Sites
        ORDER BY NEWID();

        -- Depth: at least 10ft, at most the site's max
        SET @MaxDepth   = 10 + ABS(CHECKSUM(NEWID())) % (@SiteMax - 9);

        -- Bottom time: 15–75 min
        SET @BottomTime = 15 + ABS(CHECKSUM(NEWID())) % 61;

        INSERT INTO Dive_Logs (Session_ID, Site_ID, Dive_Number, Max_Depth, Bottom_Time)
        VALUES (@SessionID, @SiteID, @j, @MaxDepth, @BottomTime);

        SET @j = @j + 1;
    END

    FETCH NEXT FROM session_cursor INTO @SessionID;
END

CLOSE session_cursor;
DEALLOCATE session_cursor;

GO

-- ============================================================
--  CLEANUP: Drop temp name tables
-- ============================================================

DROP TABLE #FirstNames;
DROP TABLE #LastNames;

GO

-- ============================================================
--  VERIFICATION: Final row counts per table
-- ============================================================

SELECT 'Certification_Agencies' AS [Table], COUNT(*) AS [Rows] FROM Certification_Agencies
UNION ALL
SELECT 'Certifications',                    COUNT(*)             FROM Certifications
UNION ALL
SELECT 'Dive_Sites',                        COUNT(*)             FROM Dive_Sites
UNION ALL
SELECT 'Instructors',                       COUNT(*)             FROM Instructors
UNION ALL
SELECT 'Divers',                            COUNT(*)             FROM Divers
UNION ALL
SELECT 'Diver_Certifications',              COUNT(*)             FROM Diver_Certifications
UNION ALL
SELECT 'Dive_Sessions',                     COUNT(*)             FROM Dive_Sessions
UNION ALL
SELECT 'Dive_Logs',                         COUNT(*)             FROM Dive_Logs;