# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

credentials_file="$1"
export GOOGLE_APPLICATION_CREDENTIALS="$credentials_file"

pip list --format=columns requests | awk 'NR>2 {print $1":"$2}' > tempfile_output_pip

# Convert pip dependencies into URL format and store in a temporary file
sed -i 's/\(.*\)"\(.*\)"/\2/g' tempfile_output_pip
sed -i 's/\(.*\)/"name": "projects\/cloud-aoss\/locations\/us\/repositories\/cloud-aoss-python\/pythonPackages\/\1",/g' tempfile_output_pip

# Store the output of the cURL command in a file
curl_output_first=$(curl -X GET -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
  "https://artifactregistry.googleapis.com/v1/projects/cloud-aoss/locations/us/repositories/cloud-aoss-python/pythonPackages?pageSize=2000" \
  | grep name | sort -f)

echo "$curl_output_first" >> tempfile_output_curl

curl_output=$(curl -X GET -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
  "https://artifactregistry.googleapis.com/v1/projects/cloud-aoss/locations/us/repositories/cloud-aoss-python/pythonPackages")

next_page_token=$(echo "$curl_output" | grep nextPageToken | awk '{print $2}' | sed 's/"//g')

while [[ -n "$next_page_token" ]]; do
    curl_output_token=$(curl -sS -X GET -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
        "https://artifactregistry.googleapis.com/v1/projects/cloud-aoss/locations/us/repositories/cloud-aoss-python/pythonPackages?pageSize=2000&pageToken=$next_page_token")
    echo "$curl_output_token" | grep name | sort -f >> tempfile_output_curl
    next_page_token=$(echo "$curl_output_token" | grep nextPageToken | awk '{print $2}' | sed 's/"//g')
done

# Initialize counters and variables
aoss_count=0
os_count=0
aoss_packages=""
os_packages=""

# Check which files from tempfile_output_pip are present in tempfile_output_curl
while IFS= read -r file; do
    if grep -q "$file" tempfile_output_curl; then
        ((aoss_count++))
        aoss_packages+="$(basename "$file" | awk -F'/' '{print $(NF-1)}')"$'\n'

    else
        ((os_count++))
    fi
done < tempfile_output_pip

# Save the final result in report.txt
echo "Number of packages coming from AOSS: $aoss_count" > report.txt
echo "Number of packages coming from public repository: $os_count" >> report.txt
echo "List of packages coming from AOSS:" >> report.txt
echo "----" >> report.txt
echo "$aoss_packages" >> report.txt

# Clean up by removing the temporary files
rm tempfile_output_pip tempfile_output_curl
