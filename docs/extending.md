# Extending

## Adding a stack

1. Create `servers/<name>/stacks/<stack>/compose.yaml`
2. Add `.env.example` for settings and secrets (use `__GENERATE_SECRET__` for passwords)
3. Add `<file>.example` for config files that are created once and then edited by hand
4. Add `hooks/after-deploy.sh` if the stack needs setup after it starts
5. Add the stack to `STACKS` in `server.env`
6. Pick a free host port from [Ports](ports.md) and add the stack to the port map
7. Add a doc in `docs/stacks/`
8. Run `update.sh` on the server

Use relative paths like `./data` for volumes so data stays in `STACKS_DIR/<stack>`.

## Adding a database for a service

1. Add the name to `SERVICE_DATABASES` in `servers/asrc/stacks/database/.env.example`
2. Add `<NAME>_DB_PASSWORD=__GENERATE_SECRET__` to the same file
3. Run `update.sh` on asrc
4. Copy the password from `/opt/stacks/database/.env` on asrc into the service `.env`

See [database](stacks/database.md) for connection strings.

## Adding a server

1. Copy an existing `servers/<name>` folder
2. Update `server.env`
3. Add or remove folders in `stacks/` and list them in `STACKS`
4. Install the Netbird client and join the network
5. Add a doc in `docs/servers/` and a section in [Ports](ports.md)
6. Run `install.sh` on the server
