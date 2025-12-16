import json
import os

def print_items(items, prefix=""):
    for item in items:
        if 'item' in item:
            print_items(item['item'], prefix + item['name'] + " / ")
        elif 'request' in item:
            url = item['request']['url']
            if isinstance(url, dict):
                url = url.get('raw', '')
            print(f"{prefix}{item['name']} -> {url}")

path = 'Royal Badminton Club.postman_collection.json'
if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
        print_items(data['item'])
else:
    print("File not found")
