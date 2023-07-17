import subprocess

aoss_command = [
    'pip',
    'install',
    '--requirement=requirements.txt',
    '--index-url',
    'https://us-python.pkg.dev/cloud-aoss/python/simple',
    '-v',
    '--no-deps',
    '--break-system-packages'
]

subprocess.call(aoss_command)