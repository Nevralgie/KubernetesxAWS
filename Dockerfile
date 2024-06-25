FROM debian:buster-slim

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssl \
    git \
    tar \
    gzip \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install python for AWS Cli
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    unzip awscliv2.zip \
    ./aws/install

# Install Helm
RUN curl -L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get_helm.sh \
    chmod 0700 /tmp/get_helm.sh \
    /tmp/get_helm.sh

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