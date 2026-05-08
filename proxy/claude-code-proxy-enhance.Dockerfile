FROM ghcr.io/astral-sh/uv:bookworm-slim

ARG PROXY_COMMIT=8a8b9eb758486c5aeca8f0d6f3a0fabaf3f6004d

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/ankitra/claude-code-proxy-enhance.git . \
    && git checkout "$PROXY_COMMIT"

RUN uv sync --locked

CMD ["uv", "run", "start_proxy.py"]