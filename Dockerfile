from neurodebian:buster-non-free
# 20201017 - use neurodebian sid. pull in afni. afni not in non-free?!
#          - afni/afni_dev_base. consider use poldracklab/fmriprep. but based on ubuntu:xenial-20200114
#          - default neurodebian repo doesn't have afni!?
# 20200909 - afni uses neurodebian:nd18.04 as base
# https://github.com/afni/afni/blob/master/.docker/afni_dev_base.dockerfile
# https://github.com/neurodebian/neurodebian/ -> bionic
run \
    apt-get update -qq \
    && apt-get install -qy neurodebian curl --no-install-recommends \
    && curl http://neuro.debian.net/lists/buster.us-tn.full  > /etc/apt/sources.list.d/neurodebian.sources.list \
    && apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends \
       afni python3-numpy python3-nibabel python3-pydicom bats octave dc r-cran-tidyverse \
    && apt-get install -qy make cpanminus \
    && rm -rf /var/lib/apt/lists/* && \
    cpanm Perl::RunEND --force
workdir /opt/lncd
ENV PATH="/opt/lncd:/usr/lib/afni/bin/:${PATH}"
add . /opt/lncd
