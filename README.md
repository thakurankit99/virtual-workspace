# Containerized VS Code Environment

This project provides a lightweight Docker container with VS Code and Firefox, accessible through a web browser.

## Features

- Ubuntu 20.04 base
- VS Code preinstalled
- Firefox browser
- XFCE4 desktop environment
- Accessible via noVNC (browser-based VNC client)

## Building the Container

```bash
docker build -t vscode-container .
```

## Running the Container

```bash
docker run -d --name vscode-env -p 8080:8080 -p 5900:5900 -v $(pwd)/workspace:/workspace vscode-container
```

This command:
- Runs the container in detached mode (`-d`)
- Maps port 8080 for noVNC web access
- Maps port 5900 for direct VNC access
- Creates a volume mapping your local `workspace` directory to `/workspace` in the container

## Accessing the Container

### Via Web Browser (Recommended)
1. Open your browser
2. Go to `http://localhost:8080/vnc.html`
3. Click "Connect" button
4. Enter the VNC password: `vncpass`

### Via VNC Client
Connect to `localhost:5900` with password `vncpass`.

## Usage

After connecting, you can use VS Code and Firefox within the container. 
Any files saved in the `/workspace` directory will persist on your host machine.

## Customization

- Change the VNC password by editing `start-vnc-session.sh`
- Add additional software by modifying the Dockerfile 