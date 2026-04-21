import pyodbc
from flask import Flask, render_template, request, redirect, url_for, flash, g
from queries import DIVER_STATS, INSTRUCTOR_STATS, SITE_STATS, AGENCY_STATS, MONTHLY_TREND # Aggregate Queries

app = Flask(__name__) # Flash app instance
app.secret_key = "scuba-secret-key" # Required for flash messages


# -------------------------------------------------------------
#                       DATABASE CONNECTION
# -------------------------------------------------------------
CONNECTION_STRING = ("DRIVER={ODBC Driver 18 for SQL Server};" "SERVER=(localdb)\\MSSQLLocalDB;" "DATABASE=ScubaDB;" "Trusted_Connection=yes;")

def get_database():
    if "db" not in g:
        g.db = pyodbc.connect(CONNECTION_STRING)
    return g.db

@app.teardown_appcontext
def close_database(error):
    db = g.pop("db", None)
    if db is not None:
        db.close()

def query_database(query, args=(), one=False, commit=False):
    connection = get_database()
    cursor = connection.cursor()
    cursor.execute(query, args)
    if commit:
        connection.commit()
        return cursor.rowcount
    cols = [column[0] for column in cursor.description]
    rows = [dict(zip(cols, row)) for row in cursor.fetchall()]
    return (rows[0] if rows else None) if one else rows


# -------------------------------------------------------------
#                           ROUTES
# -------------------------------------------------------------
# Home
@app.route("/")
def index():
    stats = {
        "divers":         query_database("SELECT COUNT(*) AS count FROM Divers WHERE Is_Removed = 0",      one=True)["count"],
        "dives":          query_database("SELECT COUNT(*) AS count FROM Dive_Logs",                        one=True)["count"],
        "sites":          query_database("SELECT COUNT(*) AS count FROM Dive_Sites WHERE Is_Removed = 0",  one=True)["count"],
        "certifications": query_database("SELECT COUNT(*) AS count FROM Diver_Certifications",             one=True)["count"],
    }
    return render_template("index.html", stats=stats)


# -------------------------------------------------------------
#                           DIVERS
# -------------------------------------------------------------
# Divers
@app.route("/divers")
def divers():
    rows = query_database(
        "SELECT * FROM Divers WHERE Is_Removed = 0 ORDER BY Last_Name, First_Name"
    )
    return render_template("divers.html", divers=rows)


# Divers Form
@app.route("/divers/new", methods=["GET", "POST"])
def diver_new():
    if request.method == "POST":
        f = request.form
        query_database(
            """INSERT INTO Divers (First_Name, Last_Name, Date_of_Birth, Email, Phone)
               VALUES (?, ?, ?, ?, ?)""",
            (
                f["first_name"],
                f["last_name"],
                f["date_of_birth"] or None,
                f["email"] or None,
                f["phone"] or None,
            ),
            commit=True,
        )
        flash("Diver added successfully.", "success")
        return redirect(url_for("divers"))
    return render_template("diver_form.html", diver=None)


# Divers Edit
@app.route("/divers/<int:diver_id>/edit", methods=["GET", "POST"])
def diver_edit(diver_id):
    diver = query_database(
        "SELECT * FROM Divers WHERE Diver_ID = ? AND Is_Removed = 0", (diver_id,), one=True
    )
    if not diver:
        flash("Diver not found.", "error")
        return redirect(url_for("divers"))
    if request.method == "POST":
        f = request.form
        query_database(
            """UPDATE Divers
               SET First_Name = ?, Last_Name = ?, Date_of_Birth = ?, Email = ?, Phone = ?
               WHERE Diver_ID = ?""",
            (
                f["first_name"],
                f["last_name"],
                f["date_of_birth"] or None,
                f["email"] or None,
                f["phone"] or None,
                diver_id,
            ),
            commit=True,
        )
        flash("Diver updated.", "success")
        return redirect(url_for("divers"))
    return render_template("diver_form.html", diver=diver)


# Divers Delete
@app.route("/divers/<int:diver_id>/delete", methods=["POST"])
def diver_delete(diver_id):
    query_database(
        "UPDATE Divers SET Is_Removed = 1 WHERE Diver_ID = ?", (diver_id,), commit=True
    )
    flash("Diver removed.", "info")
    return redirect(url_for("divers"))


# -------------------------------------------------------------
#                           SITES
# -------------------------------------------------------------
# Sites
@app.route("/dive-sites")
def dive_sites():
    rows = query_database(
        "SELECT * FROM Dive_Sites WHERE Is_Removed = 0 ORDER BY Site_Name"
    )
    return render_template("dive_sites.html", sites=rows)


# Sites Form
@app.route("/dive-sites/new", methods=["GET", "POST"])
def dive_site_new():
    if request.method == "POST":
        f = request.form
        query_database(
            """INSERT INTO Dive_Sites (Site_Name, Location, Max_Depth)
               VALUES (?, ?, ?)""",
            (f["site_name"], f["location"] or None, f["max_depth"] or None),
            commit=True,
        )
        flash("Dive site added.", "success")
        return redirect(url_for("dive_sites"))
    return render_template("dive_site_form.html", site=None)


# Sites Edit
@app.route("/dive-sites/<int:site_id>/edit", methods=["GET", "POST"])
def dive_site_edit(site_id):
    site = query_database(
        "SELECT * FROM Dive_Sites WHERE Site_ID = ? AND Is_Removed = 0", (site_id,), one=True
    )
    if not site:
        flash("Dive site not found.", "error")
        return redirect(url_for("dive_sites"))
    if request.method == "POST":
        f = request.form
        query_database(
            """UPDATE Dive_Sites
               SET Site_Name = ?, Location = ?, Max_Depth = ?
               WHERE Site_ID = ?""",
            (f["site_name"], f["location"] or None, f["max_depth"] or None, site_id),
            commit=True,
        )
        flash("Dive site updated.", "success")
        return redirect(url_for("dive_sites"))
    return render_template("dive_site_form.html", site=site)


# Sites Delete
@app.route("/dive-sites/<int:site_id>/delete", methods=["POST"])
def dive_site_delete(site_id):
    query_database(
        "UPDATE Dive_Sites SET Is_Removed = 1 WHERE Site_ID = ?", (site_id,), commit=True
    )
    flash("Dive site removed.", "info")
    return redirect(url_for("dive_sites"))


# -------------------------------------------------------------
#                            LOGS
# -------------------------------------------------------------
# Logs
@app.route("/dive-logs")
def dive_logs():
    rows = query_database(
        """SELECT
               dl.Dive_ID,
               d.First_Name + ' ' + d.Last_Name AS Diver_Name,
               ds.Session_Date,
               ds.Surface_Interval,
               si.Site_Name,
               dl.Dive_Number,
               dl.Max_Depth,
               dl.Bottom_Time
           FROM Dive_Logs dl
           JOIN Dive_Sessions ds ON ds.Session_ID = dl.Session_ID
           JOIN Divers        d  ON d.Diver_ID    = ds.Diver_ID
           JOIN Dive_Sites    si ON si.Site_ID     = dl.Site_ID
           ORDER BY ds.Session_Date DESC, dl.Dive_Number"""
    )
    return render_template("dive_logs.html", logs=rows)


# Log Form
@app.route("/dive-logs/new", methods=["GET", "POST"])
def dive_log_new():
    divers = query_database(
        "SELECT Diver_ID, First_Name + ' ' + Last_Name AS full_name FROM Divers WHERE Is_Removed = 0 ORDER BY Last_Name"
    )
    sites = query_database(
        "SELECT Site_ID, Site_Name FROM Dive_Sites WHERE Is_Removed = 0 ORDER BY Site_Name"
    )
    if request.method == "POST":
        f = request.form
        # Create session first, then log the dive against it
        query_database(
            """INSERT INTO Dive_Sessions (Diver_ID, Session_Date, Surface_Interval)
               VALUES (?, ?, ?)""",
            (f["diver_id"], f["session_date"], f["surface_interval"] or None),
            commit=True,
        )
        session = query_database(
            "SELECT TOP 1 Session_ID FROM Dive_Sessions ORDER BY Session_ID DESC", one=True
        )
        query_database(
            """INSERT INTO Dive_Logs (Session_ID, Site_ID, Dive_Number, Max_Depth, Bottom_Time)
               VALUES (?, ?, ?, ?, ?)""",
            (
                session["Session_ID"],
                f["site_id"],
                f["dive_number"] or 1,
                f["max_depth"] or None,
                f["bottom_time"] or None,
            ),
            commit=True,
        )
        flash("Dive logged.", "success")
        return redirect(url_for("dive_logs"))
    return render_template("dive_log_form.html", divers=divers, sites=sites)


# Log Delete
@app.route("/dive-logs/<int:dive_id>/delete", methods=["POST"])
def dive_log_delete(dive_id):
    query_database("DELETE FROM Dive_Logs WHERE Dive_ID = ?", (dive_id,), commit=True)
    flash("Dive log entry deleted.", "info")
    return redirect(url_for("dive_logs"))


# -------------------------------------------------------------
#                        CERTIFICATIONS
# -------------------------------------------------------------
# Certifications
@app.route("/certifications")
def certifications():
    rows = query_database(
        """SELECT
               dc.Diver_Certification_ID,
               d.First_Name + ' ' + d.Last_Name  AS Diver_Name,
               c.Certification_Name,
               ca.Agency_Name,
               i.First_Name + ' ' + i.Last_Name  AS Instructor_Name,
               dc.Certification_Number,
               dc.Date_Issued
           FROM Diver_Certifications dc
           JOIN Divers                 d  ON d.Diver_ID          = dc.Diver_ID
           JOIN Certifications         c  ON c.Certification_ID  = dc.Certification_ID
           JOIN Certification_Agencies ca ON ca.Agency_ID        = c.Agency_ID
           LEFT JOIN Instructors        i  ON i.Instructor_ID     = dc.Instructor_ID
           ORDER BY dc.Date_Issued DESC"""
    )
    return render_template("certifications.html", certs=rows)


# Certifications Form
@app.route("/certifications/new", methods=["GET", "POST"])
def certification_new():
    divers = query_database(
        "SELECT Diver_ID, First_Name + ' ' + Last_Name AS full_name FROM Divers WHERE Is_Removed = 0 ORDER BY Last_Name"
    )
    certifications_list = query_database(
        """SELECT c.Certification_ID,
                  c.Certification_Name + ' (' + ca.Agency_Name + ')' AS label
           FROM Certifications c
           JOIN Certification_Agencies ca ON ca.Agency_ID = c.Agency_ID
           ORDER BY ca.Agency_Name, c.Certification_Name"""
    )
    instructors = query_database(
        "SELECT Instructor_ID, First_Name + ' ' + Last_Name AS full_name FROM Instructors WHERE Is_Removed = 0 ORDER BY Last_Name"
    )
    if request.method == "POST":
        f = request.form
        query_database(
            """INSERT INTO Diver_Certifications
               (Diver_ID, Certification_ID, Instructor_ID, Certification_Number, Date_Issued)
               VALUES (?, ?, ?, ?, ?)""",
            (
                f["diver_id"],
                f["certification_id"],
                f["instructor_id"] or None,
                f["certification_number"] or None,
                f["date_issued"] or None,
            ),
            commit=True,
        )
        flash("Certification added.", "success")
        return redirect(url_for("certifications"))
    return render_template(
        "certification_form.html",
        divers=divers,
        certifications_list=certifications_list,
        instructors=instructors,
    )


# Certifications Delete
@app.route("/certifications/<int:cert_id>/delete", methods=["POST"])
def certification_delete(cert_id):
    query_database(
        "DELETE FROM Diver_Certifications WHERE Diver_Certification_ID = ?",
        (cert_id,),
        commit=True,
    )
    flash("Certification deleted.", "info")
    return redirect(url_for("certifications"))


# -------------------------------------------------------------
#                          ANALYTICS
# -------------------------------------------------------------
# 5 Aggregate Queries for Analytics Dashboard
@app.route("/analytics")
def analytics():
    return render_template(
        "analytics.html",
        diver_stats      = query_database(DIVER_STATS),
        instructor_stats = query_database(INSTRUCTOR_STATS),
        site_stats       = query_database(SITE_STATS),
        agency_stats     = query_database(AGENCY_STATS),
        monthly_trend    = query_database(MONTHLY_TREND),
    )

# -------------------------------------------------------------
# Required for running the app (Do not move)
if __name__ == "__main__":
    app.run(debug=True, use_reloader=False) # use_reloader=False prevent double execution?