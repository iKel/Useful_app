FROM alpine:3.17

RUN apk add --update \
    python3 \
    python3-dev \
    py-pip \
    && pip install --upgrade pip awscli boto3

# Other packages
RUN apk add --no-cache bash gawk sed grep bc coreutils make jq curl openrc docker helm
# install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv ./kubectl /usr/local/bin/kubectl
