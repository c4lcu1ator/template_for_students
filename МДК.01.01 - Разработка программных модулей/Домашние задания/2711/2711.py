with open('input.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()
print(len(lines))

with open('input.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()
with open('output_reversed.txt', 'w', encoding='utf-8') as f:
    for line in reversed(lines):
        f.write(line)

from datetime import datetime
def log_error(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open('log.txt', 'a', encoding='utf-8') as f:
        f.write(f'ERROR [{timestamp}]: {message}\n')
