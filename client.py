#!/usr/bin/env python3

import os
import sys
import socket
import string
import argparse

PORT = 20000

def pargse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('block', help='Block name')
    return parser.parse_args()

def main():
    args = pargse_args()
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect(('127.0.0.1', PORT))
        sock.send(bytes(args.block, 'ascii'))
        data = sock.recv(1024)
        print(data.decode('utf-8'))
    except Exception as exc:
        print("Exception:", exc)

if __name__ == "__main__":
    main()
