FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5-1736404155 as aws-cli-builder

RUN microdnf -y update && \
    microdnf -y install unzip gnupg2

# aws-cli
ARG CLI_URL=https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.22.35.zip

WORKDIR /tmp/build
RUN curl -s "${CLI_URL}" -o "awscliv2.zip" && \
    curl -s "${CLI_URL}.sig" -o "awscliv2.sig"

ADD aws-cli.public-pgp.key .
RUN gpg --import aws-cli.public-pgp.key && \
    gpg --verify awscliv2.sig awscliv2.zip

RUN unzip awscliv2.zip && \
    ./aws/install --install-dir /opt/awscli --bin-dir /opt/awscli/bin

FROM registry.access.redhat.com/ubi9/ubi-minimal:9.5-1736404155

COPY LICENSE /licenses/LICENSE

# postgres13 for the moment, not ideal.
RUN microdnf -y update && \
    microdnf -y install postgresql tar && \
    microdnf clean all

USER 1001:1001

COPY --from=aws-cli-builder /opt/awscli /opt/awscli
ENV PATH="$PATH:/opt/awscli/bin"

ADD diag.sh /usr/local/bin

CMD diag.sh
