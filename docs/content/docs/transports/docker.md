---
title: Docker
menu:
  docs:
    identifier: transport-docker
    parent: transports
    weight: 15
---

The Docker transport runs commands inside a running container with `docker exec`, rather than connecting over SSH or WinRM. It ships in the [kitchen-docker](https://github.com/test-kitchen/kitchen-docker) gem alongside the driver of the same name.

Using it removes the need for an SSH server inside the container, which makes images smaller, containers faster to start, and Windows containers possible at all.

```yaml
transport:
  name: docker
```

### When you need it

| Situation | Why |
| ---- | ---- |
| Windows containers | They have no WinRM service, so this transport is the only option. |
| `run_command` is not `sshd` | Anything running systemd or a custom init has no SSH server listening. |
| Minimal images | Avoids installing and running an SSH daemon just so Test Kitchen can connect. |
| Speed | `docker exec` skips SSH connection setup entirely. |

It is the recommended pairing with the Docker driver in all cases, and required in the first two.

### Setting Transport Configuration

These options go under `transport:`, not `driver:`.

| Option | Default | Description |
| ---- | ---- | ---- |
| `binary` | `docker` | Docker CLI to invoke. |
| `socket` | `$DOCKER_HOST`, else the platform default | Daemon to talk to. |
| `username` | `kitchen` on Linux, unset on Windows | User that commands run as (`-u`). |
| `working_dir` | *(none)* | Working directory inside the container (`-w`). |
| `temp_dir` | `/tmp`, or `$env:TEMP` on Windows | Directory used to stage uploaded files. |
| `env_variables` | *(none)* | Environment variables for each command. |
| `privileged` | `false` | Run commands with `--privileged`. |
| `interactive` | `false` | Pass `-i`. |
| `tty` | `false` | Pass `-t`. |
| `use_sudo` | `false` | Run every `docker` command through `sudo`. |
| `sudo_command` | `sudo -E` | The command `use_sudo` prefixes. |
| `tls` | `false` | Use TLS when connecting to the daemon. |
| `tls_verify` | `false` | Verify the daemon's certificate. |
| `tls_cacert` | *(none)* | Path to the CA certificate. |
| `tls_cert` | *(none)* | Path to the client certificate. |
| `tls_key` | *(none)* | Path to the client key. |

{{% warning %}}
The driver and transport each read their **own** copy of `binary`, `socket`, `username`, `use_sudo`, and the TLS settings. Configuring one does not configure the other. If you point the driver at a remote daemon or need `sudo` to reach the socket, set the same values under `transport:` as well — otherwise the build succeeds and the converge fails to connect.
{{% /warning %}}

### Logging in

`kitchen login` opens an interactive shell inside the running container, so you do not have to look up the container ID and run `docker exec` yourself:

```bash
kitchen login default-ubuntu-2404
```

On Linux platforms this starts `/bin/bash --login -i`; on Windows platforms it starts `powershell`. The transport's `username`, `working_dir`, `env_variables`, and `privileged` settings are honored, so the shell matches the environment the provisioner ran in.

### Examples

#### A systemd container

```yaml
driver:
  name: docker

transport:
  name: docker

platforms:
  - name: almalinux-9
    driver:
      run_command: /usr/sbin/init
      privileged: true
      volume: /sys/fs/cgroup:/sys/fs/cgroup:ro
```

Without the Docker transport this configuration cannot work: the container runs systemd rather than `sshd`, so there is nothing for an SSH transport to connect to.

#### A remote daemon over TLS

```yaml
driver:
  name: docker
  socket: tcp://docker.example.com:2376
  tls: true
  tls_verify: true
  tls_cacert: ~/.docker/ca.pem
  tls_cert: ~/.docker/cert.pem
  tls_key: ~/.docker/key.pem

transport:
  name: docker
  socket: tcp://docker.example.com:2376
  tls: true
  tls_verify: true
  tls_cacert: ~/.docker/ca.pem
  tls_cert: ~/.docker/cert.pem
  tls_key: ~/.docker/key.pem
```

Both blocks are required — this is the most common configuration mistake with this transport.

#### Running commands as root

```yaml
transport:
  name: docker
  username: root
```

#### A daemon that needs sudo

```yaml
driver:
  name: docker
  use_sudo: true

transport:
  name: docker
  use_sudo: true
```

Adding your user to the `docker` group is usually preferable to either setting.

### Troubleshooting

**The build works but the converge cannot connect.** The driver and transport are pointed at different daemons. Check that `socket`, `tls*`, and `use_sudo` match under both.

**Permission denied.** The transport runs its own `docker exec` and `docker cp`, so `use_sudo: true` on the driver alone is not enough. Set it under `transport:` too, or add your user to the `docker` group.

**Files are not where the provisioner expects.** Check `temp_dir` — the transport stages uploads there, and a read-only or missing directory will fail in ways that look like a provisioner bug.
