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
# Run pip list command and store the output in a file
pip list --format=columns requests | awk 'NR>2 {print $1":"$2}' > report.txt

# Variables to store packages from Assured OSS and Open Source
aoss_packages=()
os_packages=()

# Read each package from the file and generate the URL
while IFS= read -r package; do
    # Remove any spaces in the package
    package=${package// /}

    # Construct the URL for the package
    url="https://artifactregistry.googleapis.com/v1/projects/cloud-aoss/locations/us/repositories/cloud-aoss-python/pythonPackages/$package"

    # Execute the cURL command and capture the output
    curl_output=$(curl -s -X GET -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" "$url")

    # Check if the cURL output contains the error message
    if [[ $curl_output == *"\"status\": \"NOT_FOUND\""* ]]; then
        os_packages+=("$package")
    else
        aoss_packages+=("$package")
    fi
done < report.txt

# Create the report.txt file
report_file="report.txt"

echo "Packages coming from Assured OSS: " > "$report_file"
echo >> "$report_file"
# Append the AOSS packages to the report file
for package in "${aoss_packages[@]}"; do
    echo "$package" >> "$report_file"
done
echo >> "$report_file"

echo "Packages coming from Open Source: " >> "$report_file"
echo >> "$report_file"
# Append the OS packages to the report file
for package in "${os_packages[@]}"; do
    echo "$package" >> "$report_file"
done

# Print the report
cat "$report_file"



