import json, time, paramiko, requests
from ai_modules import report_metrics, self_update

# Load agent config
with open("agent_config.json") as f:
    CONFIG = json.load(f)

def main():
    while True:
        report_metrics(CONFIG)
        self_update(CONFIG)
        time.sleep(CONFIG.get("update_interval", 3600))

if __name__ == "__main__":
    main()
