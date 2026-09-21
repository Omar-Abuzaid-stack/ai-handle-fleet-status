# AI Handle Fleet Status

Device check-in log. Every machine running an AI Handle repo (AI-Handle-Agents-OS,
Specialized Team box, etc.) commits its own `devices/<DEVICE_ID>.json` on a cron.
A device is "online" if its last commit is recent; check the file's
`last_seen_utc` or this repo's commit history.

## Devices
Nothing has checked in yet. See `heartbeat.sh` for setup — run it on each
device once, then cron it every 5 minutes.

## Reading status
`git pull` this repo, or check `devices/*.json` on GitHub directly — each
file's `last_seen_utc` and the file's own last-commit timestamp tell you when
that device was last alive and what commit of its app repo it's running.
