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


#!/bin/bash

# Set the credentials file and export environment variable
set_credentials() {
    local credentials_file="$1"
    export GOOGLE_APPLICATION_CREDENTIALS="$credentials_file"
}

# Generate the pip dependencies list and store it in tempfile_output_pip
generate_pip_dependencies() {
    pip list --format=columns requests | awk 'NR>2 {print $1":"$2}' > tempfile_output_pip
}

# Convert pip dependencies into URL format and update tempfile_output_pip
convert_pip_dependencies() {
    sed -i 's/\(.*\)"\(.*\)"/\2/g' tempfile_output_pip
    sed -i 's/\(.*\)/"name": "projects\/cloud-aoss\/locations\/us\/repositories\/cloud-aoss-python\/pythonPackages\/\1",/g' tempfile_output_pip
}

# Fetch cURL output and store it in tempfile_output_curl
fetch_curl_output() {
    local url="https://artifactregistry.googleapis.com/v1/projects/cloud-aoss/locations/us/repositories/cloud-aoss-python/pythonPackages"
    local access_token="$(gcloud auth application-default print-access-token)"
    local next_page_token

    curl_output_first=$(curl -X GET -H "Authorization: Bearer $access_token" "$url?pageSize=2000" | grep name | sort -f)
    echo "$curl_output_first" >> tempfile_output_curl

    curl_output=$(curl -X GET -H "Authorization: Bearer $access_token" "$url")
    next_page_token=$(echo "$curl_output" | grep nextPageToken | awk '{print $2}' | sed 's/"//g')

    while [[ -n "$next_page_token" ]]; do
        curl_output_token=$(curl -sS -X GET -H "Authorization: Bearer $access_token" "$url?pageSize=2000&pageToken=$next_page_token")
        echo "$curl_output_token" | grep name | sort -f >> tempfile_output_curl
        next_page_token=$(echo "$curl_output_token" | grep nextPageToken | awk '{print $2}' | sed 's/"//g')
    done
}

# Process pip dependencies and check which packages are present in tempfile_output_curl
process_pip_dependencies() {
    local file
    local extracted_content

    while IFS= read -r file; do
        if grep -q "$file" tempfile_output_curl; then
            ((aoss_count++))
            extracted_content=$(basename "$file" | awk -F'/' '{print $(NF-1)}')
            aoss_packages+="$extracted_content"$'\n'
        else
            ((public_repo_count++))
        fi
    done < tempfile_output_pip
}

# Save the final result in report.txt
save_report() {
    cat <<EOF > report.txt
Number of packages coming from AOSS: $aoss_count
Number of packages coming from the public repository: $public_repo_count
List of packages coming from AOSS:

$aoss_packages

EOF
}

# Perform cleanup by removing the temporary files
cleanup() {
    rm tempfile_output_pip tempfile_output_curl
}

# Main script execution
main() {
    local credentials_file="$1"

    set_credentials "$credentials_file"
    generate_pip_dependencies
    convert_pip_dependencies
    fetch_curl_output

   
    local aoss_count=0
    local public_repo_count=0
    local aoss_packages=""
    local public_repo_packages=""

    process_pip_dependencies
    save_report

    cat report.txt

    cleanup
}

main "$@"
