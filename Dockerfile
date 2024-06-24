# Start from the alpine image
FROM alpine:latest

# Install AWS CLI
RUN apk add --no-cache py-pip \
    && pip install awscli \
    && rm -rf /root/.cache/pip

# Install necessary packages
RUN apk add --no-cache dpkg openssl git tar gzip build-base

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