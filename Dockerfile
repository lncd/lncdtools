from neurodebian:buster-non-free
# 20201017 - use neurodebian:buster (sid python broken?).
#          - default ND sources don't have afni? replace with ones from TN mirror.
#          - other docker options: afni/afni_dev_base;  poldracklab/fmriprep? (based on ubuntu:xenial-20200114, no tidyverse)
# 20200909 - afni uses neurodebian:nd18.04 as base
# https://github.com/afni/afni/blob/master/.docker/afni_dev_base.dockerfile
# https://github.com/neurodebian/neurodebian/ -> bionic
run \
    apt-get update -qq \
    && apt-get install -qy neurodebian curl --no-install-recommends \
    && curl http://neuro.debian.net/lists/buster.us-nh.full > /etc/apt/sources.list.d/neurodebian.sources.list \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends \
       afni python3-numpy python3-nibabel python3-pydicom bats octave dc r-cran-tidyverse dcm2niix pigz \
    && apt-get install -qy make cpanminus \
    && rm -rf /var/lib/apt/lists/* && \
    cpanm Perl::RunEND Test2::V0  File::Rename --force

# && \  curl https://github.com/SimonKagstrom/kcov/releases/download/v39/kcov-amd64.tar.gz | tar -C / -xzf -
workdir /opt/lncd
ENV PATH="/opt/lncd:/usr/lib/afni/bin/:/usr/local/bin:${PATH}"
add . /opt/lncd
