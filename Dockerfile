FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    less \
    procps \
    ripgrep \
    python3 \
    bubblewrap \
    socat \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash claude
USER claude
ENV HOME=/home/claude
ENV PATH=/home/claude/.local/bin:$PATH

# Important for Claude installer inside Docker
WORKDIR /tmp
RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR /workspace

CMD ["bash", "-lc", "exec claude"]
