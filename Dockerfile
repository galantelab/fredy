FROM galantelab/rnasamba:0.2.5 AS rnasamba-src

FROM ubuntu:20.04

LABEL maintainer="tmiller@mochsl.org.br"

# Copy python3.6 and rnasamba
COPY --from=rnasamba-src /usr/local/ /usr/local

ARG LIBFFI6_REPO=http://archive.ubuntu.com/ubuntu/pool/main/libf/libffi \
    LIBFFI6=libffi6_3.2.1-8_amd64.deb \
    STAR_REPO=https://github.com/alexdobin/STAR/archive/refs/tags \
    STAR=2.7.7a

# Install base, bedtools, gawk, gffread, hmmer, kallisto,
# parallel, r (ggplot2, reshape2), samtools, seqtk,
# stringtie, wget
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       bedtools \
       gawk \
       gffread \
       hmmer \
       kallisto \
       parallel \
       r-base \
       r-base-core \
       r-cran-ggplot2 \
       r-cran-reshape2 \
       samtools \
       seqtk \
       stringtie \
       wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install libffi6, required for python3.6
RUN wget -qP /tmp ${LIBFFI6_REPO}/${LIBFFI6} \
    && dpkg -i /tmp/${LIBFFI6} \
    && rm -f /tmp/${LIBFFI6}

# Install STAR aligner
RUN mkdir -p /tmp/${STAR} \
    && wget -qO- ${STAR_REPO}/${STAR}.tar.gz \
       | tar xz -C /tmp/${STAR} --strip-components 1 \
    && install -m 755 /tmp/${STAR}/bin/Linux_x86_64_static/* /usr/local/bin \
    && rm -rf /tmp/${STAR}

# Get the fredy source
COPY . /tmp/fredy/

# Install fredy to /usr/local
RUN make -f /tmp/fredy/Makefile install 2> /dev/null \
    && rm -rf /tmp/fredy

# Create fredy user
RUN useradd -ms /bin/bash fredy
USER fredy

# Set our workdir
VOLUME /home/fredy
WORKDIR /home/fredy

ENTRYPOINT ["fredy"]
