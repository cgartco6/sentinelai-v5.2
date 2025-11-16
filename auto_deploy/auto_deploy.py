import json, subprocess, time

with open("repo_config.json") as f:
    REPOS = json.load(f)

def deploy():
    for repo in REPOS:
        path = repo['path']
        subprocess.run(f"git -C {path} pull", shell=True)
        if repo.get('install_cmd'):
            subprocess.run(f"cd {path} && {repo['install_cmd']}", shell=True)
        if repo.get('restart_cmd'):
            subprocess.run(repo['restart_cmd'], shell=True)

if __name__ == "__main__":
    while True:
        deploy()
        time.sleep(300)  # Every 5 minutes
