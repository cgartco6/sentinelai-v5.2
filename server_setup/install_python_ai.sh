#!/bin/bash
sudo apt update
sudo apt install -y python3-pip python3-venv git build-essential
python3 -m venv /opt/sentinel_env
source /opt/sentinel_env/bin/activate
pip install --upgrade pip
pip install numpy pandas scikit-learn tensorflow torch flask paramiko psutil schedule python-dotenv
