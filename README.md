# scopy-android-deps

Apk build recipe for Scopy

Scopy is a software oscilloscope and signal analysis toolset. [The official repository](https://github.com/analogdevicesinc/scopy) provides releases for Windows, Linux, MacOS and Android.
This recipe is used to build the Android Apk installer. 


## Building the Docker image

To build the Docker image, follow these steps:

1. Ensure you're in the root directory of this repository, since the Dockerfile and secret files are referenced from this location.
2. Create the secret files:
    | File Name       | Description                                        |
    | --------------- | -------------------------------------------------- |
    | **qt_user**     | This file should contain your Qt account username. |
    | **qt_password** | This file should contain your Qt account password. |

    Expected structure:
    ```bash
    ├── docker
    │   ├── Dockerfile
    │   ├── qt_password
    │   └── qt_user
    ```

3. Run the following command to build the Docker image, replacing <REPOSITORY> with the desired repository name:

```bash
DOCKER_BUILDKIT=1 docker build --no-cache \
--secret id=qt_user,src=docker/qt_user \
--secret id=qt_password,src=docker/qt_password \
--tag <REPOSITORY>/scopy1-android:latest --file docker/Dockerfile .
```