FROM debian:buster-slim

# Install essentials
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    python3-pip \
    && pip3 install \
    && rm -rf /var/lib/apt/lists/*

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    unzip awscliv2.zip \
    ./aws/install

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssl \
    git \
    tar \
    gzip \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Download and install jq
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o jq \
    && chmod +x jq \
    && mv jq /usr/local/bin/

# Download and install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Download and install eksctl
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin