#!/usr/bin/env python3
import json
import urllib.request
import os

DATASET_URL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"
OUTPUT_FILE = os.path.join(os.path.dirname(__file__), "../database/exercises_seed.json")

def download_and_format_exercises():
    print("Connecting to free-exercise-db...")
    try:
        req = urllib.request.Request(DATASET_URL, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=15) as response:
            data = json.loads(response.read().decode('utf-8'))
            print("Downloaded", len(data), "exercises.")
            formatted = [{
                "id": item.get("id"),
                "name": item.get("name"),
                "category": item.get("category", "strength"),
                "equipment": item.get("equipment", "bodyweight"),
                "force_type": item.get("force"),
                "mechanic": item.get("mechanic"),
                "primary_muscles": item.get("primaryMuscles", []),
                "secondary_muscles": item.get("secondaryMuscles", []),
                "instructions": "\n".join(item.get("instructions", [])),
                "images": item.get("images", [])
            } for item in data]
            os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
            with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
                json.dump(formatted, f, indent=2, ensure_ascii=False)
            print("Seed file created:", OUTPUT_FILE)
    except Exception as e:
        print("Error fetching remote dataset:", e)

if __name__ == "__main__":
    download_and_format_exercises()
