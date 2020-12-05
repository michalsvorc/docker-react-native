# [React Native](https://reactnative.dev) development environment Docker image

Dockerized React Native development environment for VS Code remote development and USB connected physical Android device. Works without Android Studio.

Features:
- based on Ubuntu LTS
- Android SDK version: see repository tags
- Node.js version: v14 LTS

## Start Docker container

Use `docker.sh` script in project directory.

1. Build Docker image: execute `./docker.sh build`.
2. Run Docker image: execute `./docker.sh run`.

Docker container is not removed after exiting the application. To start the container again, execute `./docker.sh start`.

## Setup VS Code

1. Install VS Code extension [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
2. Optional: Install VS Code extension [React Native Tools](https://marketplace.visualstudio.com/items?itemName=msjsdiag.vscode-react-native).

## Connect Android device

1. Enable `Developer mode` and `USB debugging` option on your device.
2. Plug your device into your computer.
3. Select `PTP` or `MTP` connection on your device. `PTP` worked for me in most cases.
4. In VS Code, run `Attach to Running Container` command.
5. Run `adb devices` command in attached VS Code terminal and verify the output.
6. If prompted on your device, authorize your computer to access the device.

## Mount directories overview

- **workspace**: share files between the host and containerized app

You can initialize new React Native applications inside the `workspace` directory to make them persistent on host machine.

## Initialize new React Native application

1. Connect your Android device as described above.
2. Open attached VS Code terminal.
3. `cd $HOME/workspace` for persistent code base.
4. `react-native init appName`
5. `cd $HOME/workspace/appName && react-native start`
6. Open new remote terminal tab in attached VS Code.
7. `cd $HOME/workspace/appName && react-native run-android`

## Troubleshooting

### Write access to mounted directories

Mount directories must be writable by group with id `1000`. Execute these commands in project root directory:

```sh
chown -R $(id -u):1000 "${PWD}"/workspace
chmod -R g+w "${PWD}"/workspace
```

### adb: no permissions (user in plugdev group; are your udev rules wrong?)

Try running `adb kill-server` command in container and reconnect the device

### React Native white blank screen issue

Run react-native start in a separate terminal and then run react-native run-android. [Source](https://stackoverflow.com/questions/51705627/react-native-white-blank-screen-issue)
