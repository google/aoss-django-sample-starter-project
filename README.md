# AOSS-Django-Sample-Starter-Project

## Introduction
This is a simple “Hello-World” Django application written in Python, which downloads the required and available packages from Assured OSS and the rest non-available packages from PyPi Repository (open-source). The aim of this document is to define how to start working on sample starter projects using Assured OSS packages, which can help a user to quickly start using Assured OSS with minimal friction.
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

Install the latest version of python3 before running the project.

## Steps to run the project :
After cloning the project, User need to follow certain steps to get started with the project:

1. Setting up authentication via Python Keyring : 

    1. Install the keyring library using the following command:

    ```cmd
    pip install keyring
    ```

    2. Install the Artifact Registry backend using the following command:

    ```cmd
    pip install keyrings.google-artifactregistry-auth
    ```

    3. List backends to confirm the installation using the following command:

    ```cmd
    keyring --list-backends
    ```

    The list should include:
    1. ChainerBackend(priority:10)
    2. GooglePythonAuth(priority:9)

    4. For information about setting up [Application Default Credentials](https://cloud.google.com/docs/authentication#adc), see [Set up authentication](https://cloud.google.com/assured-open-source-software/docs/validate-connection#set_up_authentication).
    This step ensures that the Assured OSS credential helper obtains your key when connecting with the repositories.

2. Every Django project has a unique secret key. Create a new secret key by following the mentioned steps :

```cmd
python3
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
```
paste the key in the settings.py file.

3. Update requirements-google.txt file by adding name_of_package == version_of_package accordingly

```cmd
Django==4.2
loguru==0.7.0
name_of_package == version_of_package
```

4. Run the following command : 

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
