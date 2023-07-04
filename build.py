import subprocess


aoss_command = [
    'pip',
    'install',
    '--requirement=requirements-google.txt',
    '--index-url',
    'https://us-python.pkg.dev/cloud-aoss/cloud-aoss-python/simple',
    '-v',
    '--no-deps',
    '--break-system-packages'
]


subprocess.call(aoss_command)

os_command = [
    'pip',
    'install',
    '--requirement=requirements-google.txt',
    '--break-system-packages'
]


subprocess.call(os_command)