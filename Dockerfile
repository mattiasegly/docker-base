ARG ARCH=
ARG SOURCE_BRANCH=
FROM ${ARCH}/debian:${SOURCE_BRANCH}

RUN apt-get update && apt-get full-upgrade -y && apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	tar \
&& rm -rf /var/lib/apt/lists/*

#Balena images have issues with finding certificates. Setting variables explicitly.
ENV SSL_CERT_DIR=/etc/ssl/certs
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
