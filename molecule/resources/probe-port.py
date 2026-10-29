"""Classify a TCP port from the outside: open, closed (RST) or filtered (no answer).

A firewall that drops packets shows up as "filtered"; an allowed port with no
listener answers with a reset and shows up as "closed".
"""
import socket
import sys

host, port = sys.argv[1], int(sys.argv[2])
try:
    with socket.create_connection((host, port), timeout=3):
        print("open")
except ConnectionRefusedError:
    print("closed")
except (TimeoutError, socket.timeout):
    print("filtered")
