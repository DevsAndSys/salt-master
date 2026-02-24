ARG DEPS_IMAGE=debian:bookworm-slim
FROM ${DEPS_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive \
  PIP_NO_CACHE_DIR=1 \
  PATH="/opt/salt/bin:${PATH}"

COPY requirements.txt /tmp/requirements.txt

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    iproute2 \
    iputils-ping \
    netcat-openbsd \
    openssh-client \
    procps \
    rsync \
    sshpass \
    python3 \
    python3-venv \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/salt \
  && /opt/salt/bin/pip install --no-cache-dir -r /tmp/requirements.txt

RUN useradd --system --home-dir /var/lib/salt --shell /usr/sbin/nologin --uid 10001 salt \
  && mkdir -p /var/lib/salt/pki/master /var/lib/salt/config /var/log/salt /var/cache/salt \
  && chown -R salt:salt /var/lib/salt /var/log/salt /var/cache/salt \
  && chmod -R g+rwX /var/lib/salt /var/log/salt /var/cache/salt

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

EXPOSE 4505 4506 8000

USER salt

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
