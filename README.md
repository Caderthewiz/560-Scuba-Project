# 560-Scuba-Project
## Project Summary
The Scuba Project is a database-driven web application designed to manage scuba divers, certifications, instructors, and dive logs. The system models a realistic scuba training and logging environment where divers obtain certifications through recognized agencies, record dive sessions, and track their diving history. The database supports relationships between divers, instructors, certification agencies, courses, dive sessions, and individual dive logs.

## Technical Details
Language: Python  
Framework: Flask  
DB Connectivity: pyodbc  
Database: MSSQL

## Logical Database Model
<img width="832" height="1052" alt="Scuba ERD" src="https://github.com/user-attachments/assets/5c4969ff-a211-46ea-a401-36cb852889cc" />

## Project Setup
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
    schema.sql
    seed_data.sql
```
Running scripts in VS Code:
Install SQL Server (mssql) extension
1. Press: Ctrl-Shift-P
2. Select: MS SQL: Connect
3. Enter Connection Details:  
Server: localhost  
Authentication: Windows Authentication  
Database:  
5. Create Database: Run database/schema.sql
6. Insert Sample Data: Run database/seed_data.sql
## Running Application
```
  python app.py
```
Open browser and navigate to:
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
