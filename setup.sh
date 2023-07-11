#!/bin/bash
pip install keyring --break-system-packages
pip install keyrings.google-artifactregistry-auth --break-system-packages

# Check if the expected keyring backends are available
expected_backends=("keyring.backends.chainer.ChainerBackend (priority: 10)" "keyrings.gauth.GooglePythonAuth (priority: 9)")
available_backends=$(keyring --list-backends)

for backend in "${expected_backends[@]}"; do
  if ! grep -q "$backend" <<< "$available_backends"; then
    echo "The required keyring backend ($backend) is not available."
    exit 1
  fi
done

echo "Required backends available"

# Check if credentials file path is provided as an argument
if [ $# -eq 0 ]; then
  echo "Please provide the path to the JSON credentials file."
  exit 1
fi

# Retrieve the credentials file path from the command-line argument
credentials_file="$1"

# Run gcloud auth login with credentials file
gcloud auth login --cred-file="$credentials_file"

# Check the exit status of the gcloud auth login command
if [ $? -eq 0 ]; then
  echo "Authentication successful"
  # Export GOOGLE_APPLICATION_CREDENTIALS environment variable
  export GOOGLE_APPLICATION_CREDENTIALS="$credentials_file"
  # Run curl command to get the response
  access_token=$(gcloud auth application-default print-access-token)
  response=$(curl -sS -X GET -H "Authorization: Bearer $access_token" \
    "https://artifactregistry.googleapis.com/v1/projects/cloud-aoss/locations/us/repositories/cloud-aoss-java/mavenArtifacts?pageSize=2000")

  # Check the exit status of the curl command
  if [ $? -eq 0 ]; then
    echo "Authentication Successful, proceed with build.py"
  else
    echo "Authentication failed"
  fi
else
  echo "Authentication failed"
fi
