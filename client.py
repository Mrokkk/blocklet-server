#!/usr/bin/env python3

import os
import sys
import socket
import string
import argparse

PORT = 20000

def main():
    event = 0
    try:
        event = os.environ['BLOCK_BUTTON']
    except:
        pass
    try:
        block_name = os.environ['BLOCK_NAME']
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(('127.0.0.1', PORT))
        sock.send(bytes("{} {}".format(block_name, event), 'ascii'))
        data = sock.recv(1024)
        print(data.decode('utf-8'))
    except Exception as exc:
        print("Exception:", exc)

if __name__ == "__main__":
    main()
