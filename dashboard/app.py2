from flask import Flask, render_template
import json, threading, time, os

# Import monitoring modules (create ai_modules.py if needed)
try:
    from ai_modules import monitor_nodes, auto_heal, traffic_optimizer
except ImportError:
    def monitor_nodes(config): pass
    def auto_heal(config): pass
    def traffic_optimizer(config): pass

app = Flask(__name__)

# Load configuration
with open("config.json") as f:
    CONFIG = json.load(f)

@app.route("/")
def index():
    return render_template("index.html", nodes=CONFIG['cloud_nodes'])

# Background threads
def start_background_tasks():
    threading.Thread(target=monitor_nodes, args=(CONFIG,), daemon=True).start()
    threading.Thread(target=auto_heal, args=(CONFIG,), daemon=True).start()
    threading.Thread(target=traffic_optimizer, args=(CONFIG,), daemon=True).start()

if __name__ == "__main__":
    start_background_tasks()
    app.run(host="0.0.0.0", port=5000)
