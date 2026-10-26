"""Generate Ansible inventory from Terraform management outputs."""

import json
import os
import subprocess
from pathlib import Path

repository_root = Path(__file__).resolve().parent.parent

environment = os.environ.copy()
environment.setdefault("AWS_PROFILE", "herovired")

result = subprocess.run(
    [
        "terraform",
        "-chdir=infrastructure/management",
        "output",
        "-json",
        "jenkins_servers",
    ],
    cwd=repository_root,
    env=environment,
    check=True,
    capture_output=True,
    text=True,
)

servers = json.loads(result.stdout)
controller_ip = servers["controller"]["public_ip"]
agent_ip = servers["agent"]["public_ip"]

inventory = (
    "[jenkins_controller]\n"
    f"controller ansible_host={controller_ip}\n"
    "\n"
    "[jenkins_agent]\n"
    f"agent ansible_host={agent_ip}\n"
    "\n"
    "[all:vars]\n"
    "ansible_user=ubuntu\n"
    "ansible_ssh_private_key_file=~/.ssh/hv-capstone\n"
    "ansible_python_interpreter=/usr/bin/python3\n"
)

inventory_path = repository_root / "ansible/inventories/generated.ini"
inventory_path.parent.mkdir(parents=True, exist_ok=True)
inventory_path.write_text(inventory)

print(inventory)
