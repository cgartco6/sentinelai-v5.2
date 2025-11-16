import json, subprocess, time, os
from datetime import datetime

# Load repo config
with open("repo_config.json") as f:
    REPOS = json.load(f)

LOG_FILE = "logs/deploy.log"
os.makedirs("logs", exist_ok=True)

def log(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"[{timestamp}] {message}\n")
    print(f"[{timestamp}] {message}")

def deploy():
    for repo in REPOS:
        path = repo["path"]
        name = repo["name"]
        try:
            log(f"Deploying {name} at {path}")
            subprocess.run(f"git -C {path} pull", shell=True, check=True)
            if repo.get("install_cmd"):
                subprocess.run(f"cd {path} && {repo['install_cmd']}", shell=True, check=True)
            if repo.get("restart_cmd"):
                subprocess.run(repo["restart_cmd"], shell=True, check=True)
            log(f"{name} deployment successful")
        except subprocess.CalledProcessError as e:
            log(f"Error deploying {name}: {e}")

if __name__ == "__main__":
    while True:
        deploy()
        time.sleep(300)  # run every 5 minutes
