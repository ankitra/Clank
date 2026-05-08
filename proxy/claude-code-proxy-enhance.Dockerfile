FROM ghcr.io/astral-sh/uv:bookworm-slim

ARG PROXY_COMMIT=13265a2a0ae7ce624b5b6683fb7a2203e6927d7c

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