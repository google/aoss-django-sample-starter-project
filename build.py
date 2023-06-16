import subprocess

# Define the command
command = [
    'pip',
    'install',
    '--requirement=requirements-google.txt',
    '--index-url',
'https://_json_key_base64:{KEY}@us-python.pkg.dev/cloud-aoss/cloud-aoss-python/simple',
    '-v',
    '--no-deps',
    '--break-system-packages'
]

# Run the command
subprocess.call(command)
