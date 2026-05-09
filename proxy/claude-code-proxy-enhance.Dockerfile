FROM ghcr.io/astral-sh/uv:bookworm-slim

ARG PROXY_COMMIT=d19cb2cef89dca46fd2c43cc1408fec1bbeb331a

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