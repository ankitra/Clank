# Clank 🤖

Run Claude Code inside a disposable Docker container against a local sandbox clone of your repository.

`clank` is designed for the workflow where:

- Claude can freely edit or even destroy the mounted local sandbox clone.
- Your main working repo is separate.
- Your GitHub credentials are **not** made available inside the container.
- The Docker container stops and is removed when Claude exits.

## Features
- **Multi-Model Support**: Use Gemini 2.0, GPT-4o, or local models inside Claude Code.
- **Zero-Config Infrastructure**: Automatically manages a proxy sidecar and Docker networking.
- **Project Isolation**: Mounts individual repos as sandboxes; Claude's "memory" is isolated to that folder's `.claude` directory.

## Quick Start

1. **Clone and Run**:
   ```bash
   git clone [https://github.com/ankitra/Clank.git](https://github.com/ankitra/Clank.git)
   cd Clank
   chmod u+x install.sh
   ./install.sh
   clank --repo ~/path/to/your-project
   
## What gets installed

- `clank` launcher in `~/.local/bin` by default
- Docker support files in `~/.local/share/clank`

## Folder contents

- `Dockerfile` — basic Ubuntu image with Claude Code installed
- `clank` — launcher that builds the image if needed and starts Claude in Docker
- `install.sh` — installer and environment checker
- `Makefile` — creates GitHub-friendly zip and tar.gz release packages
- `VERSION` — single source of truth for release versioning
- `.dockerignore`

## Prerequisites

You need a working Docker CLI and a reachable Docker runtime. This can be:

- Docker Desktop
- Colima + Docker CLI
- another Docker-compatible local runtime that works with `docker info`

This toolkit checks for:

- `docker` present in `PATH`
- `docker info` succeeding
- optional `colima` presence for friendlier hints

## Install

From the toolkit directory:

```bash
chmod +x install.sh clank
./install.sh
```

If `~/.local/bin` is not already on your `PATH`, add this to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell.

## Check-only mode

To only verify that Docker is available and reachable:

```bash
./install.sh --check-only
```

## Basic usage

Use a **disposable local clone** of your repository, not your main working repo.

```bash
clank --repo ~/claude-sandboxes/myproj
```

You can also pass the repo as the first positional argument:

```bash
clank ~/claude-sandboxes/myproj
```

## Forwarding Claude arguments

Any extra arguments are passed directly to the `claude` command inside the container.

Examples:

```bash
clank --repo ~/claude-sandboxes/myproj -- --model sonnet
clank ~/claude-sandboxes/myproj --print "summarize this repo"
```

## Rebuilding the image

To force a rebuild:

```bash
clank --repo ~/claude-sandboxes/myproj --rebuild
```

## Authentication

`ANTHROPIC_API_KEY` is optional.

- If `ANTHROPIC_API_KEY` is set in the host shell, the launcher passes it into the container.
- If it is not set, Claude can rely on its own config or auth inside the container.

Example:

```bash
export ANTHROPIC_API_KEY="your-key-here"
clank --repo ~/claude-sandboxes/myproj
```

## Versioning

This kit uses a plain `VERSION` file as the release source of truth.

Current version:

```bash
cat VERSION
```

Print it through the tools:

```bash
./install.sh --version
./clank --version
make version
```

Update it:

```bash
make set-version VERSION=0.2.0
```

## Packaging for GitHub releases

The included `Makefile` creates archives under `dist/`.

```bash
make package
```

This generates both:

- `dist/claude-docker-kit-<version>.zip`
- `dist/claude-docker-kit-<version>.tar.gz`

By default, archive names use the value in `VERSION`.

```bash
make package
```

This generates:

- `dist/claude-docker-kit-$(cat VERSION).zip`
- `dist/claude-docker-kit-$(cat VERSION).tar.gz`

You can still override the package version just for one build:

```bash
make package VERSION=0.1.1-rc1
```

## Security model

This toolkit is meant for local sandboxing, not hard isolation.

The launcher:

- mounts only the repo you specify at `/workspace`
- uses a temporary container `HOME`
- unsets common GitHub and SSH auth env vars before launching Claude
- removes the container when Claude exits

You should still avoid mounting your host home directory or SSH directory into the container.

## Notes

- The image tag defaults to `claude-code-local:latest`.
- `clank --version` reads the version from the `VERSION` file next to the script.
- The launcher expects `Dockerfile` to live in the same directory as the launcher.
- The container runs interactively by default because it uses `docker run --rm -it ...`.
- The mounted repo is writable. If Claude deletes files, they are deleted from that sandbox clone on the host too.

## Uninstall

If installed with the default prefix:

```bash
rm -f "$HOME/.local/bin/clank"
rm -rf "$HOME/.local/share/clank"
```
