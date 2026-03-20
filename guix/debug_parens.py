#!/usr/bin/env python3
with open('root/keyboard.scm') as f:
    lines = f.readlines()
for i, line in enumerate(lines, 1):
    opens = line.count('(')
    closes = line.count(')')
    print(f'{i}: o={opens} c={closes} | {repr(line)}')