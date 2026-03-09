from flask import Flask, render_template, request, redirect
import pyodbc

app = Flask(__name__)

conn_str = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=(localdb)\\MSSQLLocalDb;"
    "DATABASE=ScubaDB;"
    "Trusted_Connection=yes;"
)

def get_connection():
    return pyodbc.connect(conn_str)

"""
@app.route('/')
def home():
    return render_template('index.html')
"""

@app.route('/')
def home():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Divers")  # Example table
    divers = cursor.fetchall()
    conn.close()
    return render_template('index.html', divers=divers)

# Runs server, required to be at end of file
if __name__ == "__main__":
    app.run(debug=True)