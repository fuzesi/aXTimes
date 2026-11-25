#!/usr/bin/env python3
"""Compare two aXTimes backup payloads without printing private data."""
import collections
import datetime
import json
import sys

if len(sys.argv) != 3:
    raise SystemExit("Usage: compare_backup_json.py original.json roundtrip.json")
with open(sys.argv[1], encoding="utf-8") as source:
    original = json.load(source)["kAXPayloadKey"]
with open(sys.argv[2], encoding="utf-8") as source:
    restored = json.load(source)["kAXPayloadKey"]
basic = [p for p in restored["projects"] if p.get("basicProject") and p.get("name") == "__basic__global__axtimes__project__"]
if len(basic) != 1 or not basic[0].get("id"):
    raise SystemExit("Expected one identified basic project")
basic_id = basic[0]["id"]
differences = collections.Counter()

def normalize(value, key=""):
    if isinstance(value, dict):
        value = value.copy()
        if value.get("basicProject") and value.get("name") == "__basic__global__axtimes__project__" and not value.get("id"):
            value["id"] = basic_id
        return {k: normalize(v, k) for k, v in value.items()}
    if isinstance(value, list):
        values = [normalize(item) for item in value]
        return sorted(values, key=lambda item: str(item.get("id", "")) if isinstance(item, dict) else str(item))
    if isinstance(value, str) and ("date" in key.lower() or "time" in key.lower()) and "T" in value:
        try:
            return datetime.datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp()
        except ValueError:
            pass
    return value

def compare(left, right, path):
    if isinstance(left, dict) and isinstance(right, dict):
        for key in left.keys() | right.keys():
            if key not in left or key not in right:
                differences[path + "." + key] += 1
            else:
                compare(left[key], right[key], path + "." + key)
    elif isinstance(left, list) and isinstance(right, list):
        if len(left) != len(right):
            differences[path + ".count"] += 1
        else:
            for a, b in zip(left, right):
                compare(a, b, path)
    elif left != right:
        differences[path] += 1

compare(normalize(original), normalize(restored), "payload")
print("Difference counts:", dict(differences))
raise SystemExit(1 if differences else 0)
