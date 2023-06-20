import subprocess

# Define the command
command = [
    'pip',
    'install',
    '--requirement=requirements-google.txt',
    '--index-url',
    'https://us-python.pkg.dev/cloud-aoss/cloud-aoss-python/simple',
    '-v',
    '--no-deps'
]

# Run the command
subprocess.call(command)
