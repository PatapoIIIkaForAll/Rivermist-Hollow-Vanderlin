# MTranServer translation backend

The game server translates chat between Russian and English. It sends each
line over HTTP to a local service, MTranServer
(https://github.com/xxnuo/MTranServer, Apache-2.0). MTranServer runs Mozilla's
Firefox translation models on the CPU. It needs no GPU and no internet after
setup.

It runs on the same machine as Dream Daemon. A loopback call takes a few
milliseconds and no chat text leaves the host.

## Requirements

- Windows 10 or newer, Windows PowerShell 5.1 (built in).
- Node.js LTS (18 or newer) from https://nodejs.org/en/download. Use the
  Windows Installer (.msi). The script does not install Node.js.
- Internet access during install, to fetch the npm package and the models.
- About 1 GB of free RAM and about 1 GB of disk. A test install of version
  5.4.6 with both directions used 806 MB of disk and about 410 MB of memory.

## Install

Open PowerShell as administrator in the repository folder and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\autotranslate\Install-MTranServer.ps1
```

The script ends by printing three lines. Add them to `config/autotranslate.txt`:

```
TRANSLATE_PROVIDER mtranserver
TRANSLATE_HTTP_URL http://127.0.0.1:8989
TRANSLATE_HTTP_TOKEN <the token>
```

Run the same command again to update. It keeps the existing token, so the game
config stays valid. Pass `-ApiToken` only if you want to set a new token.

Useful parameters: `-Port`, `-CpuCores`, `-DataDir`, `-RunAsCredential`,
`-SkipSmokeTest`. Run `Get-Help .\tools\autotranslate\Install-MTranServer.ps1 -Full`
for the full list.

## Remove

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\autotranslate\Install-MTranServer.ps1 -Remove -UninstallPackage
```

This stops the service and removes the task, the launcher, the token and the
npm package. It keeps the models, config and logs in
`C:\ProgramData\MTranServer`. Delete that folder by hand if you do not need it.
Leave out `-UninstallPackage` to keep the package.

## What the script changes

- Installs the `mtranserver` npm package into
  `C:\ProgramData\MTranServer\app` (a private npm prefix, not your user
  profile).
- Creates `C:\ProgramData\MTranServer` with these folders:
  - `models`: translation models.
  - `config`: the model list (`records.json`). Offline mode needs it.
  - `logs`: service and launcher logs.
  - `secrets\api-token.txt`: the API token.
  - `Start-MTranServer.ps1`: the launcher.
- Sets folder permissions: Administrators and SYSTEM have full control. Users
  can read the models and config. Only Administrators and SYSTEM can read the
  token, the launcher and the logs.
- Registers the scheduled task `MTranServer-SS13`. It runs the launcher at
  boot as SYSTEM, hidden, with no time limit. If the task fails, Windows
  restarts it 3 times, 1 minute apart. The launcher also restarts the service
  itself, up to 3 times, 1 minute apart.

The script does not change the firewall, system settings or Node.js.

## Check that it works

- Health: open `http://127.0.0.1:8989/health`. It returns `{"status":"ok"}`.
- Logs: `C:\ProgramData\MTranServer\logs`.
  - `mtran-YYYY-MM-DD.log`: service log. Kept for 14 days.
  - `stdout.log`, `stderr.log`: console output of the current run.
  - `launcher.log`: starts, exits and restarts.
- Task: `Get-ScheduledTask MTranServer-SS13` shows `Running`.
- In game: open the admin panel **Translation Control**. Type a line into the
  test box to see the translation and the time. The emergency stop there turns
  translation off for the round without touching the service.

## Resources

- Memory: the MTranServer README reports about 570 MiB with two directions
  loaded. The launcher keeps the models loaded for a day of idle time
  (`MT_WORKER_IDLE_TIMEOUT=86400`), so the first message after a quiet hour is
  not slow.
- CPU: the service runs at BelowNormal priority and only on the last
  `-CpuCores` logical cores (default 2). Dream Daemon runs mostly on one
  thread. Under load, Windows always runs it before the translator, and the
  translator can never take more than its cores. On a 6-core, 12-thread
  i5-11400 the default is cores 10 and 11, which are the two threads of one
  physical core.
- The launcher sets priority and affinity on itself before it starts
  `node.exe`, so the child inherits them. It then sets them again on
  `node.exe` and any child process. The installer prints the values it reads
  back from `node.exe`.
- To change the core count, run the install command again with
  `-CpuCores 4`. Short chat lines take a few milliseconds even on one core.

## Security

- The service listens on `127.0.0.1` only. Other machines cannot reach it.
  This is the protection that counts. Use `-BindAddress` only if the game
  server runs elsewhere, and then limit the port in the firewall to that one
  machine.
- Every translation call needs the token (`Authorization: Bearer <token>`).
  `/health` and `/version` do not.
- The token does not protect the service from a program that can reach the
  port. Version 5.4.6 serves its web page at `/ui/` even with
  `MT_ENABLE_UI=false`, and `GET /ui/api/settings` returns the settings and
  the token with no token in the request. Do not open the port to a network
  that you do not trust.
- The launcher passes the token through an environment variable, not the
  command line, so other users cannot see it in the process list.
- The update check is off. After setup the service runs in offline mode and
  makes no outbound connections. The launcher also sets `MT_ENABLE_UI=false`,
  but version 5.4.6 does not obey it.
- Do not pass `-ApiToken` on the command line on a shared machine. It stays in
  the PowerShell history. Let the script generate the token.

## Hosts behind a proxy

The model download uses the Node.js `fetch` function, and Node.js 20
does not read `HTTPS_PROXY`. On a machine that reaches the internet only
through a proxy, `npm install` works but the model download fails with
`fetch failed`. Download the models on a machine with direct access and copy
the `models` and `config` folders, or start the download with a preload file
that sets an `undici` `ProxyAgent` as the global dispatcher.

## Updating

Run the install command again. It stops the service, updates the npm package
to the latest version, downloads newer models if Mozilla published them,
rewrites the launcher and restarts the service. The service itself never
updates while running, because it runs offline.

To add a direction, pass all directions you want, for example
`-Languages 'en_ru','ru_en','en_uk','uk_en'`. To list the available
directions:

```powershell
& 'C:\ProgramData\MTranServer\app\mtranserver.cmd' --languages
```

## Optional: Docker

If the host later moves to Docker, this compose file is the equivalent. It is
based on the example in the MTranServer README. The port is published on
loopback only and the container may use at most 2 CPUs. Prepare the models
once with `MT_OFFLINE=false`, then set it to `true` and restart.

```yaml
services:
  mtranserver:
    image: xxnuo/mtranserver:latest
    container_name: mtranserver
    restart: unless-stopped
    ports:
      - "127.0.0.1:8989:8989"
    cpus: "2"
    mem_limit: 1g
    environment:
      - MT_HOST=0.0.0.0
      - MT_PORT=8989
      - MT_MODEL_DIR=/app/models
      - MT_CONFIG_DIR=/root/.config/mtran/server
      - MT_OFFLINE=false
      - MT_CPU_ONLY=true
      - MT_ENABLE_UI=false
      - MT_CHECK_UPDATE=false
      - MT_WORKER_IDLE_TIMEOUT=86400
      - MT_API_TOKEN=${MT_API_TOKEN}
    volumes:
      - ./models:/app/models
      - ./config:/root/.config/mtran
```

Put `MT_API_TOKEN=<token>` in a `.env` file next to `compose.yml`. `MT_HOST`
stays `0.0.0.0` inside the container; the `127.0.0.1:` prefix on the port keeps
it off the network.
