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
# Download install script and verify basic integrity before execution
RUN curl -fsSL -o /tmp/install.sh https://claude.ai/install.sh && \
    # Basic verification: check that file was downloaded and is not empty
    test -s /tmp/install.sh && \
    # Additional verification: check for expected content (basic sanity check)
    grep -q "claude" /tmp/install.sh && \
    # Execute the verified script
    bash /tmp/install.sh

WORKDIR /workspace

CMD ["bash", "-lc", "exec claude"]
