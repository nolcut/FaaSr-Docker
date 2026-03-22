# Stage 1: Build stage
ARG BUILD_FROM
FROM $BUILD_FROM AS build

# Install apt packages
COPY apt-packages-agent.txt /tmp/
RUN apt update && \
    xargs -a /tmp/apt-packages-agent.txt apt install -y && \
    rm /tmp/apt-packages-agent.txt && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Build and install nsjail
RUN git clone --depth 1 https://github.com/google/nsjail.git /tmp/nsjail && \
    cd /tmp/nsjail && \
    make -j$(nproc) && \
    cp nsjail /usr/local/bin/nsjail && \
    rm -rf /tmp/nsjail

# Install Python packages
COPY requirements-agent.txt /tmp/
RUN update-ca-certificates \
    && python3 -m pip config set global.break-system-packages true \
    && pip install --no-cache-dir --requirement /tmp/requirements-agent.txt && \
    rm /tmp/requirements-agent.txt

# Metadata
LABEL description="Base image for FaaSr"
