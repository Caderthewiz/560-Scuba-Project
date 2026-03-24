# 560-Scuba-Project
## Project Summary
The Scuba Project is a database-driven web application designed to manage scuba divers, certifications, instructors, and dive logs. The system models a realistic scuba training and logging environment where divers obtain certifications through recognized agencies, record dive sessions, and track their diving history. The database supports relationships between divers, instructors, certification agencies, courses, dive sessions, and individual dive logs.

## Technical Details
Language: Python  
Framework: Flask  
Connectivity: pyodbc  
Database: LocalDB

## Logical Database Model
<img width="831" height="1051" alt="Scuba ERD drawio" src="https://github.com/user-attachments/assets/1e302599-20c5-42d9-a4d0-cf1d74d2de7c" />

## Data Operations
| Table                          | SELECT | INSERT | UPDATE | DELETE |
|-------------------------------|--------|--------|--------|--------|
| Divers                        | ✔      | ✔      | ✔      | ✔      |
| DiveSession                   | ✔      | ✔      |        | ✔      |
| DiveLog                       | ✔      | ✔      |        | ✔      |
| DiveSites                     | ✔      |        |        |        |
| Certifications                | ✔      | ✔      |        |        |
| Instructors                   | ✔      | ✔      | ✔      | ✔      |
| Courses                       | ✔      |        |        |        |
| CertificationAgencies         | ✔      |        |        |        |
| SiteCertificationRequirements | ✔      |        |        |        |

## Aggregating Queries
### Query 1 — Diver Dive Profiles
**Description:** For each diver who has logged at least one dive, show their total number of dives, average maximum depth reached, average bottom time, personal depth record, and average visibility. This provides a statistical profile of each diver's experience and tendencies.
**Parameters:** None (returns all divers with logged dives).
**Result Columns:**
| Column | Description |
|---|---|
| ***Diver_ID*** | Unique identifier for the diver (GROUP BY key) |
| Diver_Name | Full name of the diver |
| Total_Dives | COUNT of all dive log entries for the diver |
| Avg_Max_Depth_m | AVG of Max_Depth across all dives |
| Avg_Bottom_Time_min | AVG of Bottom_Time across all dives |
| Personal_Depth_Record_m | MAX of Max_Depth across all dives |
| Avg_Visibility_m | AVG of Visibility across all dives |
---
### Query 2 — Instructor Certification Activity
**Description:** For each instructor, show the total number of certifications they have issued, the number of distinct courses they have taught, and the date of their most recently issued certification. Results are ranked by certification volume to identify the most active instructors.
**Parameters:** None (returns all instructors, including those with zero certifications via LEFT JOIN).
**Result Columns:**
| Column | Description |
|---|---|
| ***Instructor_ID*** | Unique identifier for the instructor (GROUP BY key) |
| Instructor_Name | Full name of the instructor |
| Agency_Acronym | Certifying agency the instructor belongs to |
| Certs_Issued | COUNT of certifications issued |
| Distinct_Courses_Taught | COUNT DISTINCT of courses taught |
| Most_Recent_Cert | MAX of Issue_Date across all certifications issued |
---
### Query 3 — Dive Site Popularity and Intensity
**Description:** For each dive site, aggregate the total number of dives recorded there, the average maximum depth reached by divers, the average underwater visibility, and the average gas consumed per dive (pressure in minus pressure out). This reveals which sites are most visited and which are physically demanding.
**Parameters:** None (returns all sites, including unvisited ones via LEFT JOIN).
**Result Columns:**
| Column | Description |
|---|---|
| ***Site_ID*** | Unique identifier for the dive site (GROUP BY key) |
| Site_Name | Name of the dive site |
| Location | Geographic location of the site |
| Dive_Type | Category of dive (Reef, Wreck, Cave, etc.) |
| Total_Dives | COUNT of all dive log entries at this site |
| Avg_Max_Depth_m | AVG of Max_Depth across all dives at the site |
| Avg_Visibility_m | AVG of Visibility across all dives at the site |
| Avg_Gas_Consumed_Bar | AVG of (Pressure_In − Pressure_Out) across all dives |
---
### Query 4 — Certification Agency Reach
**Description:** Compare certification agencies by the number of active instructors affiliated with them, the number of unique divers they have certified, the number of courses they offer, and their total certifications issued. This acts as a market-share-style report across the three agencies in the system.
**Parameters:** None (returns all agencies).
**Result Columns:**
| Column | Description |
|---|---|
| ***Agency_ID*** | Unique identifier for the agency (GROUP BY key) |
| Agency_Acronym | Short name of the agency |
| Agency_Name | Full name of the agency |
| Active_Instructors | COUNT DISTINCT of instructors affiliated with the agency |
| Unique_Divers_Certified | COUNT DISTINCT of divers holding a cert from this agency |
| Courses_Offered | COUNT DISTINCT of courses offered by the agency |
| Total_Certs_Issued | COUNT of all certifications issued through the agency |
---
### Query 5 — Monthly Dive Activity Trend
**Description:** Aggregate dive activity by calendar month, showing how dive volume, number of unique divers active, average maximum depth, and average bottom time change over time. This trend report helps identify peak diving seasons and shifts in diver behavior month over month.
**Parameters:** None (returns all months present in the DiveLog table).
**Result Columns:**
| Column | Description |
|---|---|
| ***Month_Label*** | Year-month string in `yyyy-MM` format (GROUP BY key) |
| Total_Dives | COUNT of dive log entries in the month |
| Unique_Divers | COUNT DISTINCT of divers who dove that month |
| Avg_Max_Depth_m | AVG of Max_Depth for all dives in the month |
| Avg_Bottom_Time_min | AVG of Bottom_Time for all dives in the month |
---

## Project Setup
Download:
- Python 3.15/3.16 - https://www.python.org/downloads/
- SQL Server Express LocalDB - https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/sql-server-express-localdb?view=sql-server-ver17
- ODBC Driver for SQL Server - https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver17

Steup Commands:
```
  git clone <repo-url>
  cd 560-Scuba-Project
  python -m venv venv
  venv\Scripts\activate
  pip install Flask pyodbc
```

## Database Setup
Database script are located in:
```
  database/
    create_database.sql
    schema.sql
    seed_data.sql
```
Running SQL scripts in VS Code:
1. Install: SQL Server (mssql) extension
2. Press: Ctrl-Shift-P
3. Select: MS SQL: Connect
4. Create Database: Run create_database.sql
5. Setup Database Schema: Run schema.sql
6. Insert Sample Data: Run seed_data.sql

## Running Application
```
  python app.py
```
Open browser and navigate to (Terminal generates link to click):
```
  http://localhost:5000
```

## Collaboration Notes
The database runs locally for each team member:
- The database itself is not stored in the repository
- Only the SQL scripts used to create the database are stored
- Each member runs the scripts locally to recreate the same schema  

All development should follow this workflow:
- Pull latest code from GitHub
- Run schema.sql if database changes occur
- Run seed_data.sql if new sample data is added
- Run the Flask application locally
- Create local feature-branch
- Commit changes on feature-branch
- Push feature branch to remote
- Create Pull Request in GitHub
