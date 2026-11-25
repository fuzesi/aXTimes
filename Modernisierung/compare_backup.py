#!/usr/bin/env python3
"""Compare an aXTimes Pro JSON backup with a restored Core Data SQLite store.

Only aggregate mismatch counts are printed; individual user data is not displayed.
Usage: python3 compare_backup.py /path/to/backup.json /path/to/aXTimes.sqlite
"""
import datetime
import json
import sqlite3
import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit(__doc__)
with open(sys.argv[1], encoding="utf-8") as source:
    payload = json.load(source)["kAXPayloadKey"]
database_uri = Path(sys.argv[2]).resolve().as_uri() + "?mode=ro"
db = sqlite3.connect(database_uri, uri=True)

tables = {"dayEntries": "ZDAYENTRY", "pauses": "ZPAUSE", "projects": "ZPROJECT", "customers": "ZCUSTOMER", "dayTypes": "ZDAYTYPE"}
failures = 0
for key, table in tables.items():
    expected = len(payload[key])
    actual = db.execute("SELECT COUNT(*) FROM " + table).fetchone()[0]
    print(f"{key}: backup={expected}, restored={actual}")
    failures += expected != actual

rows = {row[0]: row for row in db.execute("""
    SELECT d.ZIDENTIFIER, d.ZCHECKINTIME, d.ZCHECKOUTTIME,
           d.ZCHECKINTIMEZONE, d.ZCHECKOUTTIMEZONE, d.ZCOMMENT,
           p.ZIDENTIFIER, p.ZBASICPROJECT
    FROM ZDAYENTRY d LEFT JOIN ZPROJECT p ON p.Z_PK = d.ZPROJECT
""")}
errors = {"missing": 0, "time": 0, "zones": 0, "comment": 0, "project": 0}

def coredata_date(value):
    if not value:
        return None
    return datetime.datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp() - 978307200

for entry in payload["dayEntries"]:
    row = rows.get(entry["id"])
    if row is None:
        errors["missing"] += 1
        continue
    try:
        dates = ((coredata_date(entry.get("checkInTime")), row[1]),
                 (coredata_date(entry.get("checkOutTime")), row[2]))
        if any((a is None) != (b is None) or (a is not None and abs(a - b) > 0.01) for a, b in dates):
            errors["time"] += 1
    except (TypeError, ValueError):
        errors["time"] += 1
    if (entry.get("checkInTimeZone"), entry.get("checkOutTimeZone")) != (row[3], row[4]):
        errors["zones"] += 1
    if entry.get("comment") != row[5]:
        errors["comment"] += 1
    project = entry.get("project") or {}
    identifier = project.get("id")
    if (identifier and identifier != row[6]) or (not identifier and (not project.get("basicProject") or not row[7])):
        errors["project"] += 1
print("Entry mismatches:", errors)
failures += sum(errors.values())

expected = {(entry["id"], pause["id"]) for entry in payload["dayEntries"]
            for pause in entry.get("pauses", []) if pause.get("id")}
actual = set(db.execute("SELECT d.ZIDENTIFIER, p.ZIDENTIFIER FROM ZPAUSE p JOIN ZDAYENTRY d ON d.Z_PK=p.ZDAYENTRY"))
print(f"Pause links: missing={len(expected - actual)}, extra={len(actual - expected)}")
failures += len(expected - actual) + len(actual - expected)
raise SystemExit(1 if failures else 0)
