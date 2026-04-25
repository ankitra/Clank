FROM ghcr.io/astral-sh/uv:bookworm-slim

ARG PROXY_COMMIT=d3befb748b7d392871e807cd54f6f168ad6e49fb

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/zimplexing/claude-code-proxy-enhance.git . \
    && git checkout "$PROXY_COMMIT"

RUN uv sync --locked

CMD ["uv", "run", "start_proxy.py"]