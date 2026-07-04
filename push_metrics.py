#!/usr/bin/env python3
import socket
import time
import subprocess
import re

GRAPHITE_HOST = "localhost"
GRAPHITE_PORT = 2003
WEBSITE_URL = "http://localhost:8081"

def send_to_graphite(metric, value, timestamp):
    msg = f"{metric} {value} {timestamp}\n"
    try:
        sock = socket.socket()
        sock.settimeout(5)
        sock.connect((GRAPHITE_HOST, GRAPHITE_PORT))
        sock.sendall(msg.encode())
        sock.close()
    except Exception as e:
        print(f"Error sending to Graphite: {e}")

def get_cpu():
    try:
        result = subprocess.run(["top", "-l", "1", "-n", "0"], capture_output=True, text=True, timeout=5)
        for line in result.stdout.splitlines():
            if "CPU usage" in line:
                match = re.search(r'([\d.]+)%\s+user.*?([\d.]+)%\s+sys', line)
                if match:
                    return round(float(match.group(1)) + float(match.group(2)), 2)
    except Exception:
        pass
    return 0.0

def get_memory_mb():
    try:
        result = subprocess.run(["vm_stat"], capture_output=True, text=True, timeout=5)
        pages_active, pages_wired = 0, 0
        for line in result.stdout.splitlines():
            if "Pages active" in line:
                pages_active = int(re.search(r'(\d+)', line).group(1))
            elif "Pages wired down" in line:
                pages_wired = int(re.search(r'(\d+)', line).group(1))
        return round((pages_active + pages_wired) * 4096 / 1024 / 1024, 2)
    except Exception:
        pass
    return 0.0

def get_response_time_ms():
    try:
        result = subprocess.run(
            ["curl", "-s", "-o", "/dev/null", "-w", "%{time_total}", WEBSITE_URL],
            capture_output=True, text=True, timeout=10
        )
        return round(float(result.stdout.strip()) * 1000, 2)
    except Exception:
        pass
    return -1.0

print("Starting metrics push to Graphite...")
while True:
    ts = int(time.time())
    resp = get_response_time_ms()
    cpu = get_cpu()
    mem = get_memory_mb()
    send_to_graphite("website.response_time_ms", resp, ts)
    send_to_graphite("website.cpu_percent", cpu, ts)
    send_to_graphite("website.memory_mb", mem, ts)
    print(f"[{time.strftime('%H:%M:%S')}] response={resp}ms  cpu={cpu}%  mem={mem}MB")
    time.sleep(10)
