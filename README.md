# 560-Scuba-Project
## Project Summary
The Scuba Project is a database-driven web application designed to manage scuba divers, certifications, instructors, and dive logs. The system models a realistic scuba training and logging environment where divers obtain certifications through recognized agencies, record dive sessions, and track their diving history. The database supports relationships between divers, instructors, certification agencies, courses, dive sessions, and individual dive logs.

## Technical Details
Language: Python  
Framework: Flask  
Connectivity: pyodbc  
Database: LocalDB

## Logical Database Model
<img width="832" height="1052" alt="Scuba ERD" src="https://github.com/user-attachments/assets/5c4969ff-a211-46ea-a401-36cb852889cc" />

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
