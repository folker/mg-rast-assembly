# MG-RAST dockerfiles

FROM	debian
MAINTAINER The MG-RAST team

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y locales -qq && locale-gen en_US.UTF-8 en_us && dpkg-reconfigure locales && dpkg-reconfigure locales && locale-gen C.UTF-8 && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

RUN echo 'DEBIAN_FRONTEND=noninteractive' >> /etc/environment

RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  bowtie2 \
  cython \
  dh-autoreconf \
  git \
  hmmer \
  zlib1g-dev \
  mafft \
  mothur \
  ncbi-blast+  \
  perl \
  python \
  python-pip \
  samtools \
  unzip \
  wget \
  curl 

# ###########
# copy files into image

	
### install vsearch 2.02
RUN cd /root \
	&& wget https://github.com/torognes/vsearch/archive/v2.0.2.tar.gz \
	&& tar xzf v2.0.2.tar.gz \
	&& cd vsearch-2.0.2 \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr/local/ \
	&& make \
	&& make install \
	&& make clean \
	&& cd .. \
    && rm -rf /root/vsearch-2.02 /root/v2.0.2.tar.gz


### megahit
RUN cd /root \
	&& git clone https://github.com/voutcn/megahit.git \
	&& cd megahit \
	&& make \
	&& install -m755 megahit megahit_asm_core megahit_toolkit megahit_sdbg_build /usr/local/bin

# install cutadapt (we do not use the debian unstable source package)
RUN pip install cutadapt 
