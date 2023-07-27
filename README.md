# AOSS-Django-Sample-Starter-Project

## Introduction
This is a simple “Hello-World” Django application written in Python, which downloads the required and available packages from Assured OSS and the rest non-available packages from PyPi Repository (open-source). The aim of this document is to define how to start working on sample starter project which can help a user to quickly start using Assured OSS with minimal friction.
Users can refer to [Assured Open Source Software](https://cloud.google.com/assured-open-source-software) for further reading and information about Assured OSS.

## Installation : 
Run the following command to clone the project in your local setup: 

```cmd
git clone https://github.com/google/aoss-django-sample-starter-project.git
```

## Prerequisite : 
1. Install the latest version of the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install).
2. If you have installed the Google Cloud CLI previously, make sure you have the latest version by running the command:

```cmd
gcloud components update
```
3. To enable access to Assured OSS, submit the [customer enablement form](https://developers.google.com/assured-oss#get-started).
4. [Validate connectivity](https://cloud.google.com/assured-open-source-software/docs/validate-connection) to Assured OSS for the requested service accounts.
5. [Enable the Artifact Registry API](https://cloud.google.com/artifact-registry/docs/enable-service) for the parent Google Cloud project of the service accounts used to access Assured OSS.
6. You should have python3/python 3.8+ downloaded and configured on your system. You can verify their installations by running python3 --version command in the command prompt or terminal.

## Steps to start working on project
1. User should run setup.sh script before doing anything,in order to download backends as well as run and check the installation and authentication on their system. The script will guide them what went wrong and it is mandatory to run this before starting build tool. 

Run the following command after inserting path_to_service_account_key to execute the setup script:

```cmd
chmod +x setup.sh 
sudo ./setup.sh path_to_service_account_key
```
Once the setup is completed it will say "Authentication successful, Proceed with build.py"
Refer to [set up authentication](https://cloud.google.com/assured-open-source-software/docs/validate-connection#set_up_authentication) for further information.

2. After the setup is complete the user should run 

```cmd
python3 build.py
```
to download required packages
 
3. In case user want to look at the report of what packages are downloaded from Assured OSS and Open Source as well, they can run generate_report.sh script after inserting path_to_service_account_key to execute the setup script

```cmd
chmod +x generate_report.sh
./generate_report.sh path_to_service_account_key
```
The following report will be stored as report.txt in the root directory.

## Steps to make changes and extend the project 

1. Every Django project has a unique secret key. Create a new secret key by following the mentioned steps :

```cmd
python3
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
```
paste the key in the settings.py file in place of config('DJANGO_SECRET_KEY').

2. Update requirements.txt file by adding name_of_package == version_of_package accordingly

```cmd
Django==4.2
loguru==0.7.0
name_of_package == version_of_package
```

3. Run the following command : 

```cmd
python3 build.py
python3 manage.py runserver
```

All the required packages will get downloaded, and users can import it to start working with it. 
You have the basic framework to start working with Django Application along with the Logging library, to see output which is “Hello,World”, open http://127.0.0.1:8000/hello/.
In case you get stuck in any process refer to [Download Python packages using direct repository access](https://cloud.google.com/assured-open-source-software/docs/download-python-packages).

## Additional Information : 
Ideally it is preferred to use authentication via Keyring but user can also authenticate via service key :

### Setting up the Authentication via Service Key :

Users have to replace the KEY present in settings.xml file, with the base64-encoding of the entire service account JSON key file. To do this, execute following command:

```cmd
cat KEY_FILE_LOCATION | base64
```
Where KEY_FILE_LOCATION is the location of the service account JSON key file.

Modify the build.py file according to : 

```cmd
import subprocess

command = [
    'pip',
    'install',
    '--requirement=requirements-google.txt',
    '--index-url',
'https://_json_key_base64:{KEY}@us-python.pkg.dev/cloud-aoss/cloud-aoss-python/simple',
    '-v',
    '--no-deps',
]


subprocess.call(command)
```

Replace the {KEY} with key obtained from above command

Refer to [Authenticate using Service](https://cloud.google.com/assured-open-source-software/docs/download-python-packages) key for more information.
