# Clank 🤖

Run Claude Code inside a disposable Docker container against a local sandbox clone of your repository.

`clank` is designed for the workflow where:

- Claude can freely edit or even destroy the mounted local sandbox clone.
- Your main working repo is separate.
- Your GitHub credentials are **not** made available inside the container.
- The Docker container stops and is removed when Claude exits.

## Features

- **Multi-Model Support** — Use Gemini, GPT-4o, or local models via the built-in proxy sidecar.
- **Zero-Config Infrastructure** — Automatically manages the proxy sidecar and Docker networking.
- **Project Isolation** — Mounts individual repos as sandboxes; Claude's memory is isolated to that folder's `.claude` directory.

## Prerequisites

You need a working Docker CLI and a reachable Docker runtime. This can be:

- Docker Desktop
- Colima + Docker CLI
- another Docker-compatible local runtime that works with `docker info`

The toolkit checks for:

- `docker` present in `PATH`
- `docker info` succeeding
- optional `colima` presence for friendlier hints

## Installation

1. Clone and run the installer:

```bash
git clone https://github.com/ankitra/Clank.git
cd Clank
chmod +x install.sh clank
./install.sh
```

2. If `~/.local/bin` is not already on your `PATH`, add this to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

3. Then reload your shell.

### What gets installed

| Location | Contents |
|---|---|
| `~/.local/bin/clank` | The launcher script |
| `~/.local/share/clank` | Docker support files |

To verify Docker is reachable without installing:

```bash
./install.sh --check-only
```

## Usage

Use a **disposable local clone** of your repository, not your main working repo.

### Basic

```bash
clank --repo ~/claude-sandboxes/myproj
```

Positional repo argument also works:

```bash
clank ~/claude-sandboxes/myproj
```

### Forwarding Claude arguments

Extra arguments are passed directly to the `claude` command inside the container.

```bash
clank --repo ~/claude-sandboxes/myproj -- --model sonnet
clank ~/claude-sandboxes/myproj --print "summarize this repo"
```

### Forcing an image rebuild

```bash
clank --repo ~/claude-sandboxes/myproj --rebuild
```

### Authentication

`ANTHROPIC_API_KEY` is optional.

- If set in the host shell, it is passed into the container.
- If not set, Claude uses its own config or auth inside the container.

```bash
export ANTHROPIC_API_KEY="your-key-here"
clank --repo ~/claude-sandboxes/myproj
```

## Multi-Model Support (Proxy Sidecar)

`clank` starts a proxy sidecar (`clank-proxy`) on the `clank-net` Docker bridge network. The proxy routes LLM requests and allows you to use models other than Anthropic.

Configure API keys for other providers in the proxy Web UI:

```
http://localhost:8082
```

Once keys are configured there, you can pass `--model` to switch models:

```bash
clank --repo ~/claude-sandboxes/myproj -- --model gemini-2.0-flash
clank --repo ~/claude-sandboxes/myproj -- --print "hello" --model gpt-4o
```

## Security Model

This toolkit is meant for local sandboxing, not hard isolation.

The launcher:

- Mounts only the repo you specify at `/workspace`
- Uses a temporary container `HOME`
- Sets `GIT_TERMINAL_PROMPT=0` and `GIT_CONFIG_GLOBAL=/dev/null`
- Unsets common GitHub and SSH auth env vars before launching Claude (`GH_TOKEN`, `GITHUB_TOKEN`, `GIT_ASKPASS`, `SSH_ASKPASS`, `SSH_AUTH_SOCK`)
- Removes the container when Claude exits

You should still avoid mounting your host home directory or SSH directory into the container.

## Versioning

This kit uses a plain `VERSION` file as the release source of truth.

```bash
cat VERSION
./install.sh --version
./clank --version
make version
```

Update the version:

```bash
make set-version VERSION=0.2.0
```

## Packaging for GitHub Releases

The included `Makefile` creates archives under `dist/`. Archive names default to the value in `VERSION`.

```bash
make package
```

This generates:

- `dist/claude-docker-kit-<version>.zip`
- `dist/claude-docker-kit-<version>.tar.gz`

Override the version for a single build:

```bash
make package VERSION=0.1.1-rc1
```

## Notes

- The Docker image tag defaults to `claude-code-local:latest`.
- `clank --version` reads the version from the `VERSION` file next to the script.
- The launcher expects `Dockerfile` to live in the same directory as the launcher.
- The container runs interactively by default (`docker run --rm -it ...`).
- The mounted repo is writable. If Claude deletes files, they are deleted from that sandbox clone on the host too.
- The proxy sidecar (`clank-proxy`) and Docker network (`clank-net`) are created once and reused across invocations.

## Uninstall

If installed with the default prefix:

```bash
rm -f "$HOME/.local/bin/clank"
rm -rf "$HOME/.local/share/clank"
```