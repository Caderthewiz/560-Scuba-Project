# Imported by app.py for analytics aggregate queries

DIVER_STATS = """
    SELECT
        d.First_Name + ' ' + d.Last_Name AS Diver_Name,
        COUNT(dl.Dive_ID)                AS Total_Dives,
        AVG(dl.Max_Depth)                AS Avg_Max_Depth,
        MAX(dl.Max_Depth)                AS Personal_Record_Depth,
        AVG(dl.Bottom_Time)              AS Avg_Bottom_Time,
        SUM(dl.Bottom_Time)              AS Total_Bottom_Time
    FROM Divers d
    JOIN Dive_Sessions ds ON ds.Diver_ID   = d.Diver_ID
    JOIN Dive_Logs     dl ON dl.Session_ID = ds.Session_ID
    WHERE d.Is_Removed = 0
    GROUP BY d.Diver_ID, d.First_Name, d.Last_Name
    ORDER BY Total_Dives DESC
"""
 
INSTRUCTOR_STATS = """
    SELECT
        i.First_Name + ' ' + i.Last_Name  AS Instructor_Name,
        ca.Agency_Name,
        COUNT(dc.Diver_Certification_ID)  AS Certs_Issued,
        COUNT(DISTINCT dc.Diver_ID)        AS Unique_Divers_Certified,
        MAX(dc.Date_Issued)                AS Most_Recent_Cert
    FROM Instructors i
    JOIN Certification_Agencies  ca ON ca.Agency_ID     = i.Agency_ID
    LEFT JOIN Diver_Certifications dc ON dc.Instructor_ID = i.Instructor_ID
    WHERE i.Is_Removed = 0
    GROUP BY i.Instructor_ID, i.First_Name, i.Last_Name, ca.Agency_Name
    ORDER BY Certs_Issued DESC
"""
 
SITE_STATS = """
    SELECT
        si.Site_Name,
        si.Location,
        COUNT(dl.Dive_ID)    AS Total_Dives,
        AVG(dl.Max_Depth)    AS Avg_Max_Depth,
        MAX(dl.Max_Depth)    AS Deepest_Dive,
        AVG(dl.Bottom_Time)  AS Avg_Bottom_Time
    FROM Dive_Sites si
    LEFT JOIN Dive_Logs dl ON dl.Site_ID = si.Site_ID
    WHERE si.Is_Removed = 0
    GROUP BY si.Site_ID, si.Site_Name, si.Location
    ORDER BY Total_Dives DESC
"""
 
AGENCY_STATS = """
    SELECT
        ca.Agency_Name,
        COUNT(DISTINCT i.Instructor_ID)    AS Instructors,
        COUNT(DISTINCT c.Certification_ID) AS Certs_Offered,
        COUNT(dc.Diver_Certification_ID)   AS Total_Certs_Issued,
        COUNT(DISTINCT dc.Diver_ID)        AS Unique_Divers_Certified
    FROM Certification_Agencies ca
    LEFT JOIN Certifications           c  ON c.Agency_ID        = ca.Agency_ID
    LEFT JOIN Diver_Certifications     dc ON dc.Certification_ID = c.Certification_ID
    LEFT JOIN Instructors              i  ON i.Agency_ID         = ca.Agency_ID
    GROUP BY ca.Agency_ID, ca.Agency_Name
    ORDER BY Total_Certs_Issued DESC
"""
 
MONTHLY_TREND = """
    SELECT
        FORMAT(ds.Session_Date, 'yyyy-MM') AS Month_Label,
        COUNT(dl.Dive_ID)                  AS Total_Dives,
        COUNT(DISTINCT ds.Diver_ID)        AS Unique_Divers,
        AVG(dl.Max_Depth)                  AS Avg_Max_Depth,
        AVG(dl.Bottom_Time)                AS Avg_Bottom_Time
    FROM Dive_Sessions ds
    JOIN Dive_Logs dl ON dl.Session_ID = ds.Session_ID
    GROUP BY FORMAT(ds.Session_Date, 'yyyy-MM')
    ORDER BY Month_Label
"""