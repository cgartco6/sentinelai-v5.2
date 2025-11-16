from flask import Flask, render_template
import json, threading, time, os
from ai_modules import monitor_nodes, auto_heal, traffic_optimizer

app = Flask(__name__)

# Load configuration
with open("config.json") as f:
    CONFIG = json.load(f)

@app.route("/")
def index():
    return render_template("index.html", nodes=CONFIG['cloud_nodes'])

# Background Threads
def start_background_tasks():
    threading.Thread(target=monitor_nodes, args=(CONFIG,)).start()
    threading.Thread(target=auto_heal, args=(CONFIG,)).start()
    threading.Thread(target=traffic_optimizer, args=(CONFIG,)).start()

if __name__ == "__main__":
    start_background_tasks()
    app.run(host="0.0.0.0", port=5000)
