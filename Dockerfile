FROM --platform=linux/amd64 debian:bookworm-slim

ARG REGISTRY_USER
ARG REGISTRY_TOKEN
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_REGION

ENV REGISTRY_USER ${REGISTRY_USER}
ENV REGISTRY_TOKEN ${REGISTRY_TOKEN}
ENV AWS_ACCESS_KEY_ID ${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY ${AWS_SECRET_ACCESS_KEY}
ENV AWS_REGION ${AWS_REGION}

COPY aws.pub .

RUN set -ex; \
  apt-get update; \
  apt-get install -y --reinstall ca-certificates; \
  apt-get install -y --no-install-recommends \
    curl \
    dnf \
    gpg \
    gpg-agent \
    lsb-release \
    libc6-dev \
    libc6-dbg \
    less \
    unzip \
    wget

RUN set -ex; \
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list; \
  apt update && apt install -y terraform; \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"     -o "awscliv2.zip"; \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig" -o "awscliv2.sig"; \
  gpg --import aws.pub; \
  gpg --verify awscliv2.sig awscliv2.zip && \
  unzip awscliv2.zip && \
  rm -rf awscliv2.zip && \
  rm -rf awscliv2.sig && \
  rm -rf aws.pub && \
  ./aws/install && \
  /usr/local/bin/aws --version

WORKDIR code

CMD ["bash"]