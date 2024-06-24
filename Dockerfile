# Start from a base image
FROM amazon/aws-cli

# Update the package lists
RUN yum update -y

# Install necessary packages
RUN yum install -y dpkg openssl git tar gzip build-essential

# Download and install k8sgpt
RUN curl -LO https://github.com/k8sgpt-ai/k8sgpt/releases/download/v0.3.37/k8sgpt_amd64.deb \
    && dpkg -i k8sgpt_amd64.deb

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