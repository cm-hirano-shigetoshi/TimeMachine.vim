#!/usr/bin/env python
import os
import sys
import argparse
import subprocess
from subprocess import PIPE

sys.stdout.reconfigure(line_buffering=True)

p = argparse.ArgumentParser()
p.add_argument('file')
args = p.parse_args()


def print_one_line(line):
    sp = line.split(' ')
    commit = sp[0]
    comment = ' '.join(sp[1:])
    print(commit, end=':')
    print(comment, end='')
    print(' ' * 256, end=':')
    proc = subprocess.run("git show {}:{}".format(commit, args.file),
                          shell=True,
                          stdout=PIPE,
                          text=True)
    print(proc.stdout.replace('\n', '\\n'))

try:
    line = sys.stdin.readline()
    while line:
        line = line.strip("\n")
        print_one_line(line)
        line = sys.stdin.readline()
except BrokenPipeError:
    devnull = os.open(os.devnull, os.O_WRONLY)
    os.dup2(devnull, sys.stdout.fileno())
    sys.exit(1)
