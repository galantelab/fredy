FROM antoniopcamargo/rnasamba:latest AS rnasamba-src

FROM ubuntu:20.04

LABEL maintainer="tmiller@mochsl.org.br"

# Copy python3.6 and rnasamba
COPY --from=rnasamba-src /usr/local/bin/ /usr/local/bin
COPY --from=rnasamba-src /usr/local/lib/ /usr/local/lib

# Install base, bedtools, gffread, hmmer, kallisto, r (ggplot2, reshape2), stringtie, parallel
# Also install libffi6, required for python3.6

RUN set -e; \
    \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      --no-install-recommends \
      bedtools \
      gffread \
      hmmer \
      kallisto \
      r-base \
      r-base-core \
      r-cran-ggplot2 \
      r-cran-reshape2 \
      stringtie \
      seqtk \
      parallel \
      wget; \
    wget -qP / \
      http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb; \
    dpkg -i /libffi6_3.2.1-8_amd64.deb; \
    apt-get clean; \
    rm -rf /libffi6_3.2.1-8_amd64.deb /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip uninstall -y tensorflow
RUN yes | pip install tensorflow==1.5

VOLUME ["/app/freddie"]

COPY . /app/freddie

WORKDIR /home/

ENTRYPOINT ["/app/freddie/freddie"]
